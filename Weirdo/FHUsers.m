//
//  FHUsers.m
//  Weirdo
//
//  Created by FengHuan on 14-3-20.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHUsers.h"
#import "FHImageCache.h"

@implementation FHUsers

+ (FHUsers *)sharedUsers
{
    static FHUsers *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        users = [[NSMutableDictionary alloc] init];
        fetchImageQueue = [[NSOperationQueue alloc] init];
        [fetchImageQueue setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (void)fetchImageForID:(NSString *)userID
{
    FHUser *user = [users objectForKey:userID];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.profileImageURL]];
    UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    user.profileImage = image;
    [users setObject:user forKey:userID];
}

- (void)addUser:(FHUser *)user
{
    FHUser *exsitedUser = [users objectForKey:user.ID];
    if (exsitedUser && exsitedUser.profileImage && [exsitedUser.profileImageURL isEqualToString:user.profileImageURL]) {
        return;
    }
    [users setObject:user forKey:user.ID];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchImageForID:) object:user.ID];
    [fetchImageQueue addOperation:operation];
}

- (FHUser *)getUserForID:(NSString *)userID
{
    return [users objectForKey:userID];
}

- (FHUser *)getCurrentUser
{
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    return [self getUserForID:currentUserID];
}

@end
