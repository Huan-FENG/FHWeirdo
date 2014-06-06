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

#define ERROR_TOKEN_INVALID 21314
#define ERROR_AUTHORIZE_DID_NOT_COMPLETED 00005

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
- (NSError *)isAuthorized:(NSURL *)redirectURL;

- (void)fetchUserPostsLaterThanPost:(FHPost *)post interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchHomePostsNewer:(BOOL)newer thanPost:(FHPost *)post interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchBilateralPostsNewer:(BOOL)newer thanPost:(FHPost *)post interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchPublicPostsWithInteractionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchImagesForURL:(NSString *)URLString interactionProperty:(FHConnectionInterationProperty *)property;
- (void)fetchCommentForStatus:(NSNumber *)statusID laterThanComment:(NSNumber *)commentID interactionProperty:(FHConnectionInterationProperty *)property;

- (void)retweetStatus:(NSNumber *)statusID content:(NSString *)content commentTo:(int)commentType interactionProperty:(FHConnectionInterationProperty *)property;
- (void)commentStatus:(NSNumber *)statusID content:(NSString *)content commentTo:(int)commentType interactionProperty:(FHConnectionInterationProperty *)property;
- (void)replyComment:(NSNumber *)commentID Status:(NSNumber *)statusID content:(NSString *)content commentTo:(int)commentType interactionProperty:(FHConnectionInterationProperty *)property;
- (NSDictionary *)checkVersion;

@end
