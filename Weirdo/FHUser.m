//
//  FHUser.m
//  Weirdo
//
//  Created by FengHuan on 14-3-20.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHUser.h"
#import "FHUsers.h"

@implementation FHUser

@synthesize ID, name, location, description, profileImageURL, profileImage;
@synthesize followersCount, friendsCount, postsCount;

- (id)initWithUserDic:(NSDictionary *)original
{
    if (self) {
        ID = [original objectForKey:@"idstr"]? : nil;
        name = [original objectForKey:@"screen_name"]? :@"地球人";
        location = [original objectForKey:@"location"]? :@"地球";
        description = [original objectForKey:@"description"]? :@"这家伙很懒，什么都没有留下";
        profileImageURL = [original objectForKey:@"profile_image_url"]? :nil;
        followersCount = [original objectForKey:@"followers_count"]? : @"0";
        friendsCount = [original objectForKey:@"friends_count"]? : @"0";
        postsCount = [original objectForKey:@"statuses_count"]? : @"0";
    }
    [[FHUsers sharedUsers] addUser:self];
    return self;
}
@end
