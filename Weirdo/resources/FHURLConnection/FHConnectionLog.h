//
//  FHConnectionLog.h
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-4.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface FHConnectionLog : NSObject
{
    NSOperationQueue *cacheQueue;
    NSString *cachePath;
    NSFileManager *defaultFileManager;
    BOOL isFinishWritingFile;
    NSString *token;
    NSString *logID;
}

+ (FHConnectionLog *)sharedLog;
+ (NSString *)logIdentifer;
+ (long long)getUploadedSize;
- (void)cacheConnectionLog:(NSString *)log;

@end
