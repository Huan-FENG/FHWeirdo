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

#define KEY_UPLOAD_ACCESS_ID @"KKHq1zh79ZQvnk2F"
#define KEY_UPLOAD_ACCESS_KEY @"ESh0HLSJvgWlRQqe837m0S20jIEAgE"
#define KEY_UPLOAD_ENDPOINT @"http://oss-cn-beijing.aliyuncs.com"
#define KEY_UPLOAD_BUCKET @"weirdo"
#define KEY_LOG_UPLOADED_SIZE @"logUploadedSize"
#define upload_size_threshold 1024*1024*1

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

+ (long long)getUploadedSize
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_LOG_UPLOADED_SIZE] longLongValue];
}

- (NSString *)URLEncodedString:(NSString *)string
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,
                                                                                                    (CFStringRef)string, nil,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
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
    logUploadClient = [[OSSClient alloc] initWithEndPoint:KEY_UPLOAD_ENDPOINT AccessId:KEY_UPLOAD_ACCESS_ID andAccessKey:KEY_UPLOAD_ACCESS_KEY];
    logUploadClient.delegate = self;
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
    if ([defaultFileManager fileExistsAtPath:[[cachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"waitToUploadLog"]]) {
        [self uploadLog];
    }else{
    
        NSDictionary *logAttr = [defaultFileManager attributesOfItemAtPath:cachePath error:nil];
        if (logAttr) {
            long long size = [[logAttr objectForKey:NSFileSize] longLongValue];
            if (size > upload_size_threshold) {
                [self uploadLog];
            }
        }
    }
}

- (void)uploadLog
{
    if ([[UIDevice currentDevice].model rangeOfString:@"Simulator"].location != NSNotFound) {
        return;
    }
    
    NSString *uploadLogPath = [[cachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"waitToUploadLog"];
    if (![self checkLogExistence:uploadLogPath]) {
        [cacheQueue setSuspended:YES];
        while (!isFinishWritingFile) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [defaultFileManager moveItemAtPath:cachePath toPath:uploadLogPath error:nil];
        [cacheQueue setSuspended:NO];
    }
    [self uploadLogToCloud:uploadLogPath];
}

- (void)uploadLogToCloud:(NSString *)logFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    NSString *path = [NSString stringWithFormat:@"%@/%@.txt", [FHConnectionLog logIdentifer], date];
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    ObjectMetadata * objMetadata = [[ObjectMetadata alloc] init];
    [logUploadClient putObject:KEY_UPLOAD_BUCKET key:path data:data objectMetadata:objMetadata];
}

#pragma mark
#pragma mark - OSSClientDelegate

- (void)OSSObjectPutObjectFinish:(OSSClient*) client result:(PutObjectResult*) result
{
    NSString *uploadLogPath = [[cachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"waitToUploadLog"];
    long long previousUploadedSize = [FHConnectionLog getUploadedSize];
    long long uploadedSize = [[[defaultFileManager attributesOfItemAtPath:uploadLogPath error:NULL] objectForKey:NSFileSize] longLongValue] + previousUploadedSize;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:uploadedSize] forKey:KEY_LOG_UPLOADED_SIZE];
    [defaultFileManager removeItemAtPath:uploadLogPath error:nil];
    
    NSDictionary *logAttr = [defaultFileManager attributesOfItemAtPath:cachePath error:nil];
    if (logAttr) {
        long long size = [[logAttr objectForKey:NSFileSize] longLongValue];
        if (size > upload_size_threshold) {
            [self uploadLog];
        }
    }
}

@end
