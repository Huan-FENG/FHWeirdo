//
//  FHConnectionParse.h
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-3.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHConnectionParse : NSObject

+ (void)parseRequest:(NSURLRequest *)request forConnectionID:(NSString *)connectionId;
+ (void)parseResponse:(NSURLResponse *)response forConnectionID:(NSString *)connectionId;
+ (void)parseResponseData:(NSData *)data forConnectionID:(NSString *)connectionId;
+ (NSString *)parseConnectionLog:(NSDictionary *)connectionLog;

@end
