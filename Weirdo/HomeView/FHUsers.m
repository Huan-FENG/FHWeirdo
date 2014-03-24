//
//  FHUsers.m
//  Weirdo
//
//  Created by FengHuan on 14-3-20.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHUsers.h"

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
    if (self) {
        users = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addUser:(FHUser *)user
{
    [users setObject:user forKey:user.ID];
}

- (FHUser *)getUserForID:(NSString *)userID
{
    return [users objectForKey:userID];
}
@end
