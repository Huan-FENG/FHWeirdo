//
//  FHConnectionLog.m
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-4.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHConnectionLog.h"
#import "FHConnectionParse.h"
#import <CommonCrypto/CommonDigest.h>
#define KEY_LOGTOKEN @"logToken"
#define KEY_LOGID @"logID"

@implementation FHConnectionLog

+ (NSString *)logIdentifer
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (FHConnectionLog *)sharedLog
{
    static FHConnectionLog *sharedLogInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLogInstance = [[self alloc] init];
    });
    return sharedLogInstance;
}

- (id)init
{
    isFinishWritingFile = YES;
    cacheQueue = [[NSOperationQueue alloc] init];
    [cacheQueue setMaxConcurrentOperationCount:1];
    [self setCachePath];
    [NSTimer scheduledTimerWithTimeInterval:24*60*60.0 target:self selector:@selector(uploadLog) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60*60.0 target:self selector:@selector(checkLogSizeForUpload) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundUpload) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

- (void)backgroundUpload
{
    UIApplication *application = [UIApplication sharedApplication];
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //### background task starts
            [self checkLogSizeForUpload];
            //#### background task ends
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        });
    }
    else
    {
        NSLog(@"Multitasking Not Supported");
    }
    
}

- (void)cacheConnectionLog:(NSString *)log
{
    NSInvocationOperation *cacheLogOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeSingleLog:) object:log];
    [cacheQueue addOperation:cacheLogOperation];
}

- (BOOL)setCachePath
{
    BOOL isDir;
    if (cachePath && [defaultFileManager fileExistsAtPath:cachePath isDirectory:&isDir] && !isDir) {
        return YES;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ConnectionLog"];
    defaultFileManager = [NSFileManager defaultManager];
    if (![defaultFileManager fileExistsAtPath:cacheDirectory isDirectory:&isDir] || !isDir) {
        if (![defaultFileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"ERROR! Create cache dir failed: [%@]", cacheDirectory);
            return NO;
        }
    }
    cachePath = [cacheDirectory stringByAppendingPathComponent:@"Log.txt"];
    if ([defaultFileManager fileExistsAtPath:cachePath isDirectory:&isDir] && !isDir) {
        return YES;
    }
    
    if (![defaultFileManager createFileAtPath:cachePath contents:nil attributes:nil]){
        NSLog(@"ERROR! Create cache file failed: [%@]", cachePath);
        return NO;
    }else{
        NSString *line = [FHConnectionParse parseConnectionLog:nil];
        [self cacheConnectionLog:line];
    }
    return YES;
}

- (void)writeSingleLog:(NSString *)log
{
    if (!cachePath && ![self setCachePath]){
        NSLog(@"ERROR! CacheConnectionLog failed! Log: [%@]", log);
        return;
    }
    isFinishWritingFile = NO;
    NSData *logData = [log dataUsingEncoding:NSASCIIStringEncoding];
    if (!logData) {
        logData = [log dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:cachePath];
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:logData];
    [fileHandler closeFile];
    isFinishWritingFile = YES;
}

- (BOOL)checkLogExistence:(NSString *)logPath;
{
    BOOL isDir;
    return [defaultFileManager fileExistsAtPath:logPath isDirectory:&isDir] && !isDir;
}

- (void)checkLogSizeForUpload
{
    NSDictionary *logAttr = [defaultFileManager attributesOfItemAtPath:cachePath error:nil];
    if (logAttr) {
        long long size = [[logAttr objectForKey:NSFileSize] longLongValue];
        if (size > 1024*1024*2) {
            [self uploadLog];
        }
    }
}

- (void)uploadLog
{
    NSString *uploadLogPath = [[cachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"waitToUploadLog"];
    if (![self checkLogExistence:uploadLogPath]) {
        [cacheQueue setSuspended:YES];
        while (!isFinishWritingFile) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [defaultFileManager moveItemAtPath:cachePath toPath:uploadLogPath error:nil];
        [cacheQueue setSuspended:NO];
    }
    
    BOOL uploadCompleted = NO;
    if ([self getLogToken] && [self getLogID]) {
        for (int i = 0; i < 2; i++) {
            uploadCompleted = [self uploadLogToCloud:uploadLogPath];
            if (uploadCompleted)
                break;
            else{
                i = 0? [self getLogToken] : [self getLogID];
                uploadCompleted = [self uploadLogToCloud:uploadLogPath];
                if (uploadCompleted)
                    break;
                else
                    continue;
            }
        }
    }
    
    if (uploadCompleted) {
        [defaultFileManager removeItemAtPath:uploadLogPath error:nil];
    }
}

- (BOOL)getLogID
{
    logID = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LOGID];
    if (!logID) {
        return [self idOfLogCloud];
    }
    return YES;
}

- (BOOL)resetLogID
{
    return [self idOfLogCloud];
}

- (BOOL)idOfLogCloud
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.meepotech.com/0/account/info?count=0&token=%@",token] ;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:50.0f];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!responseData) {
        return NO;
    }
    NSDictionary *recievedJsonToDic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    logID = [recievedJsonToDic objectForKey:@"user_id"];
    if (logID) {
        [[NSUserDefaults standardUserDefaults] setObject:logID forKey:KEY_LOGID];
        return YES;
    }
    return NO;
}

- (BOOL)getLogToken
{
    token = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LOGTOKEN];
    if (!token) {
        return [self loginLogCloud];
    }
    return YES;
}

- (BOOL)resetLogToken
{
    return [self loginLogCloud];
}

- (BOOL)loginLogCloud
{
    NSString *logPsw = @"cc89051718";
    NSString *device = [NSString stringWithFormat:@"%@", [FHConnectionLog logIdentifer]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.meepotech.com/0/account/login?user_name=c30268056&password=%@&device_name=%@", logPsw, device]] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:50.0f];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!responseData) {
        return NO;
    }
    NSDictionary *recievedJsonToDic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    token = [recievedJsonToDic objectForKey:@"token"];
    if (token) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:KEY_LOGTOKEN];
        return YES;
    }
    return NO;
}

- (BOOL)uploadLogToCloud:(NSString *)logFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    NSString *path = [NSString stringWithFormat:@"%@/%@.txt", [[[UIDevice currentDevice] identifierForVendor] UUIDString], date];
    path = [self URLEncodedString:path];
    NSString *urlString = [NSString stringWithFormat:@"https://api-content.meepotech.com/0/groups/%@/roots/meepo/files/%@?token=%@&modified=%.0f", logID, path, token, [[NSDate date] timeIntervalSince1970]*1000];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:50.0f];
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *recievedJsonToDic;
    NSLog(@"%ld",(long)response.statusCode);
    if (response.statusCode == 200 && responseData) {
        recievedJsonToDic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    }
    if (error || [recievedJsonToDic objectForKey:@"error_code"]) {
        return NO;
    }
    return YES;
}

- (NSString *)URLEncodedString:(NSString *)string
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,
                                                                                                    (CFStringRef)string, nil,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}

@end
