//
//  FHConnectionLog.h
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-4.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOpenServiceSDK/OSS.h>

@interface FHConnectionLog : NSObject <OSSClientDelegate>
{
    OSSClient *logUploadClient;
    NSOperationQueue *cacheQueue;
    NSString *cachePath;
    NSFileManager *defaultFileManager;
    BOOL isFinishWritingFile;
}

+ (FHConnectionLog *)sharedLog;
+ (NSString *)logIdentifer;
+ (long long)getUploadedSize;
- (void)cacheConnectionLog:(NSString *)log;

@end
