//
//  FHWeiBoAPI.h
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHConnectionInterationProperty.h"

@interface FHWeiBoAPI : NSObject
{
    NSMutableDictionary *connections;
    NSString *appKey;
    NSString *appSecretKey;
    NSString *token;
    NSString *uid;
}

+ (FHWeiBoAPI *)sharedWeiBoAPI;

- (NSURL *)authorizeURL;
- (BOOL)isAuthorized:(NSURL *)redirectURL;
@end
