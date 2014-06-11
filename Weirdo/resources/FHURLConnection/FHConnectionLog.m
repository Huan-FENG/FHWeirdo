//
//  FHConnectionLog.m
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-4.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHConnectionLog.h"
#import "FHConnectionParse.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

#define KEY_UPLOAD_ACCESS_ID @"KKHq1zh79ZQvnk2F"
#define KEY_UPLOAD_ACCESS_KEY @"ESh0HLSJvgWlRQqe837m0S20jIEAgE"
#define KEY_UPLOAD_ENDPOINT @"http://oss-cn-beijing.aliyuncs.com"
#define KEY_UPLOAD_BUCKET @"weirdov2"
#define KEY_LOG_UPLOADED_SIZE @"logUploadedSize"
#define upload_size_threshold 1024*1024*1

#define KEY_CACH_LOG 1

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

- (long long)getToUploadSize
{
    long long size = 0;
    if ([defaultFileManager fileExistsAtPath:cachePath]) {
        size = size + [[[defaultFileManager attributesOfItemAtPath:cachePath error:NULL] objectForKey:NSFileSize] longLongValue];
    }
    if ([defaultFileManager fileExistsAtPath:waitToUploadRoot]) {
        NSArray *waitLogs = [defaultFileManager contentsOfDirectoryAtPath:waitToUploadRoot error:NULL];
        for (NSString *name in waitLogs) {
            if ([name hasPrefix:@"."]) {
                [defaultFileManager removeItemAtPath:[waitToUploadRoot stringByAppendingPathComponent:name] error:nil];
                continue;
            }
            size = size + [[[defaultFileManager attributesOfItemAtPath:[waitToUploadRoot stringByAppendingPathComponent:name] error:NULL] objectForKey:NSFileSize] longLongValue];
        }
    }
    return size;
}

- (void)sycUploadDataSizeToNotfication:(NSString *)name
{
    NSError *error;
    long long size = [self ossGetObjectsSize:&error];
    id postObj;
    if (error) {
        postObj = error;
    }else
        postObj = [NSNumber numberWithLongLong:size];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:postObj];
        
    });
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
    self = [super init];
    if (self) {
        isUploading = NO;
        isFinishWritingFile = YES;
        cacheQueue = [[NSOperationQueue alloc] init];
        [cacheQueue setMaxConcurrentOperationCount:1];
        [self setCachePath];
        [self setUploadLogPath];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundUpload) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
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
    if (KEY_CACH_LOG) {
        NSInvocationOperation *cacheLogOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeSingleLog:) object:log];
        [cacheQueue addOperation:cacheLogOperation];
    }
}

- (BOOL)setUploadLogPath
{
    BOOL isDir;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    waitToUploadRoot = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"UploadingLog"];
    defaultFileManager = [NSFileManager defaultManager];
    if (![defaultFileManager fileExistsAtPath:waitToUploadRoot isDirectory:&isDir] || !isDir) {
        if (![defaultFileManager createDirectoryAtPath:waitToUploadRoot withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"ERROR! Create upload dir failed: [%@]", waitToUploadRoot);
            return NO;
        }
    }
    return YES;
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
    
    if (![self setCachePath]){
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
    NSArray *waitLogs = [defaultFileManager contentsOfDirectoryAtPath:waitToUploadRoot error:NULL];
    for (NSString *name in waitLogs) {
        if ([name hasPrefix:@"."]) {
            continue;
        }
        [self uploadLog];
        return;
    }
    NSDictionary *logAttr = [defaultFileManager attributesOfItemAtPath:cachePath error:nil];
    if (logAttr) {
        long long size = [[logAttr objectForKey:NSFileSize] longLongValue];
        if (size > upload_size_threshold) {
            [self uploadLog];
        }
    }
}

- (void)uploadLog
{
    if ([[UIDevice currentDevice].model rangeOfString:@"Simulator"].location != NSNotFound) {
        return;
    }
    
    NSString *uploadLogPath;
    NSArray *waitLogs = [defaultFileManager contentsOfDirectoryAtPath:waitToUploadRoot error:NULL];
    for (NSString *name in waitLogs) {
        if ([name hasPrefix:@"."]) {
            continue;
        }
        uploadLogPath = [waitToUploadRoot stringByAppendingPathComponent:name];
    }
    
    if (!uploadLogPath) {
        [cacheQueue setSuspended:YES];
        while (!isFinishWritingFile) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
        NSString *date = [formatter stringFromDate:[NSDate date]];
        NSString *path = [NSString stringWithFormat:@"%@.txt", date];
        uploadLogPath = [waitToUploadRoot stringByAppendingPathComponent:path];
        [defaultFileManager moveItemAtPath:cachePath toPath:uploadLogPath error:nil];
        [cacheQueue setSuspended:NO];
    }
    [self uploadLogToCloud:uploadLogPath];
}

- (void)uploadLogToCloud:(NSString *)logFilePath
{
    if (isUploading) {
        return;
    }
    isUploading = YES;
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    [self ossPutObjectAtPath:[[FHConnectionLog logIdentifer] stringByAppendingString:[logFilePath substringFromIndex:waitToUploadRoot.length]] data:data];
}

-(void)uploadCompleted
{
    NSString *uploadLogPath;
    NSArray *waitLogs = [defaultFileManager contentsOfDirectoryAtPath:waitToUploadRoot error:NULL];
    
    for (NSString *name in waitLogs) {
        if ([name hasPrefix:@"."]) {
            [defaultFileManager removeItemAtPath:[waitToUploadRoot stringByAppendingPathComponent:name] error:nil];
        }else{
            uploadLogPath = [waitToUploadRoot stringByAppendingPathComponent:name];
            long long previousUploadedSize = [FHConnectionLog getUploadedSize];
            long long uploadedSize = [[[defaultFileManager attributesOfItemAtPath:uploadLogPath error:NULL] objectForKey:NSFileSize] longLongValue] + previousUploadedSize;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:uploadedSize] forKey:KEY_LOG_UPLOADED_SIZE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [defaultFileManager removeItemAtPath:uploadLogPath error:nil];
            
            NSDictionary *logAttr = [defaultFileManager attributesOfItemAtPath:cachePath error:nil];
            if (logAttr) {
                long long size = [[logAttr objectForKey:NSFileSize] longLongValue];
                if (size > upload_size_threshold) {
                    [self uploadLog];
                }
            }
            
        }
    }

}

#pragma mark
#pragma mark - OSS

- (long long)ossGetObjectsSize:(NSError **)error
{
    long long size = 0;
    NSString *url = [NSString stringWithFormat:@"%@/?prefix=%@&delimiter=%@", KEY_UPLOAD_ENDPOINT, [[FHConnectionLog logIdentifer] stringByAppendingString:@"%2F"], [self URLEncodedString:@"/"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:50.0];
    [request setHTTPMethod:@"GET"];
    NSDate *date = [NSDate date];
    [request addValue:[self setAuthorizationString:request.HTTPMethod resourcePath:nil date:date] forHTTPHeaderField:@"Authorization"];
    [request addValue:[[FHConnectionLog Rfc822DateFomatter] stringFromDate:date] forHTTPHeaderField:@"Date"];
    [request addValue:[NSString stringWithFormat:@"%@.%@", KEY_UPLOAD_BUCKET, [KEY_UPLOAD_ENDPOINT stringByReplacingOccurrencesOfString:@"http://" withString:@""]] forHTTPHeaderField:@"Host"];
//    DLog(@"requestHeaders: %@", request.allHTTPHeaderFields);
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSError *e;
    NSData *rdata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&e];
    if (e && error) {
        *error = e;
        return size;
    }
    
    NSMutableString *rsting = [[NSMutableString alloc] initWithData:rdata encoding:NSUTF8StringEncoding];
//    DLog(@"%@", rsting);
    if (response && response.statusCode == 200) {
        while (true) {
            NSRange srange = [rsting rangeOfString:@"<Size>"];
            if (srange.location == NSNotFound) {
                break;
            }
            [rsting deleteCharactersInRange:NSMakeRange(0, srange.location+srange.length)];
            NSRange erange = [rsting rangeOfString:@"</Size>"];
            size = [[rsting substringToIndex:erange.location] longLongValue] + size;
            [rsting deleteCharactersInRange:NSMakeRange(0, erange.location+erange.length)];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:size] forKey:KEY_LOG_UPLOADED_SIZE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        if (error) {
            *error = [NSError errorWithDomain:@"AliyunDomain" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"系统错误"}];
        }
    }
    return size;
}

- (void)ossPutObjectAtPath:(NSString *)path data:(NSData *)data
{
    NSString *url = [NSString stringWithFormat:@"%@/%@", KEY_UPLOAD_ENDPOINT, [self URLEncodedString:path]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:50];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:data];
    NSDate *date = [NSDate date];
    [request addValue:[self setAuthorizationString:request.HTTPMethod resourcePath:path date:date] forHTTPHeaderField:@"Authorization"];
    [request addValue:[[FHConnectionLog Rfc822DateFomatter] stringFromDate:date] forHTTPHeaderField:@"Date"];
    [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request addValue:[NSString stringWithFormat:@"%@.%@", KEY_UPLOAD_BUCKET, [KEY_UPLOAD_ENDPOINT stringByReplacingOccurrencesOfString:@"http://" withString:@""]] forHTTPHeaderField:@"Host"];
//    DLog(@"requestHeaders: %@", request.allHTTPHeaderFields);
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    isUploading = NO;
    if (response && response.statusCode == 200) {
//        DLog(@"上传成功");
        [self uploadCompleted];
    }
}

-(NSString*) setAuthorizationString:(NSString *)httpMethod resourcePath:(NSString*)resourcePath date:(NSDate *)date
{
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"%@\n\n", httpMethod];
    if ([httpMethod isEqualToString:@"PUT"]) {
        [content appendString:@"application/octet-stream\n"];
    }else{
        [content appendString:@"\n"];
    }
    [content appendString:[[FHConnectionLog Rfc822DateFomatter] stringFromDate:date]];
    [content appendString:@"\n"];
    [content appendString:[NSString stringWithFormat:@"/%@/", KEY_UPLOAD_BUCKET]];
    if (resourcePath) {
        [content appendString:[NSString stringWithFormat:@"%@", resourcePath]];
    }
    NSString *signitureSuffix = [self hmac:content withKey:KEY_UPLOAD_ACCESS_KEY];
    NSString *authorize = [NSString stringWithFormat:@"OSS %@:%@", KEY_UPLOAD_ACCESS_ID, signitureSuffix];
    return authorize;
}

-(NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *Hash1 = [HMAC base64Encoding];
    return Hash1;
}

+(NSDateFormatter*) Rfc822DateFomatter
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [inputFormatter setTimeZone:tz];
    return inputFormatter ;
}

@end
