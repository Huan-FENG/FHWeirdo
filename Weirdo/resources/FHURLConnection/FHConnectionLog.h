//
//  FHConnectionLog.h
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-4.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHConnectionLog : NSObject
//<OSSClientDelegate>
{
    //OSSClient *logUploadClient;
    NSOperationQueue *cacheQueue;
    NSString *waitToUploadRoot;
    NSString *cachePath;
    NSFileManager *defaultFileManager;
    BOOL isFinishWritingFile;
    BOOL isUploading;
}

+ (FHConnectionLog *)sharedLog;
+ (NSString *)logIdentifer;
+ (long long)getUploadedSize;
- (long long)getToUploadSize;
- (void)cacheConnectionLog:(NSString *)log;
- (void)sycUploadDataSizeToNotfication:(NSString *)name;
@end
