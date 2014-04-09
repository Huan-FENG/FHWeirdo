//
//  FHWeiBoAPI.h
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHConnectionInterationProperty.h"
#import "FHPost.h"

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

- (void)fetchHomePostsNewer:(BOOL)newer thanPost:(FHPost *)post interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchBilateralPostsNewer:(BOOL)newer thanPost:(FHPost *)post interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchPublicPostsWithInteractionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchImagesForURL:(NSString *)URLString interactionProperty:(FHConnectionInterationProperty *)property;
- (void)retweetStatus:(NSNumber *)statusID content:(NSString *)content commentTo:(int)commentType interactionProperty:(FHConnectionInterationProperty *)property;
@end
