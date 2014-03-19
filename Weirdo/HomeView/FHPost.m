//
//  FHPost.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHPost.h"

@implementation FHPost

@synthesize favorited, createdTime, ID, text, source, picURLs;
@synthesize retweeted, userID, userImageURLString, username;
@synthesize reporstsCount, commentsCount, voteCounts;

- (id)initWithOriginalData:(NSDictionary *)original
{
    if (self) {
        favorited = [original objectForKey:@"favorited"]? [[original objectForKey:@"favorited"] boolValue]: NO;
//        createdTime = []
    }
    
    return self;
}
@end
