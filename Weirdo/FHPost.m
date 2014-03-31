//
//  FHPost.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHPost.h"
#import "FHUser.h"

@implementation FHPost

@synthesize favorited, createdTime, ID, text, source, picURLs;
@synthesize retweeted, userID, username;
@synthesize reporstsCount, commentsCount, voteCounts;

- (id)initWithPostDic:(NSDictionary *)original
{
    if (self) {
        favorited = [original objectForKey:@"favorited"]? [[original objectForKey:@"favorited"] boolValue]: NO;
        createdTime = [original objectForKey:@"created_at"]? [self formatCreatedTime:[original objectForKey:@"created_at"]] : @"从前";
        ID = [original objectForKey:@"idstr"]? : nil;
        text = [original objectForKey:@"text"]? : nil;
        source = [original objectForKey:@"source"]? [self formatSource:[original objectForKey:@"source"]]: @"地球";
        picURLs = [original objectForKey:@"pic_urls"]? [self formatThumbnails:[original objectForKey:@"pic_urls"]]: nil;
        reporstsCount = [original objectForKey:@"reposts_count"]? : @"0";
        commentsCount = [original objectForKey:@"comments_count"]? : @"0";
        voteCounts = [original objectForKey:@"attitudes_count"]? : @"0";
        
        if ([original objectForKey:@"user"]) {
            FHUser *user = [[FHUser alloc] initWithUserDic:[original objectForKey:@"user"]];
            userID = user.ID;
            username = user.name;
//            userImageURLString = user.profileImageURL;
        }
        
        NSDictionary *originalRetweet = [original objectForKey:@"retweeted"];
        if (originalRetweet)
            retweeted = [[FHPost alloc] initWithPostDic:originalRetweet];
    }
    
    return self;
}

- (NSString *)formatCreatedTime:(NSString *)originalCreatedTime
{
    NSString *formatCreatedTime;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
    NSDate *dateTime = [formatter dateFromString:originalCreatedTime];

    formatter.dateFormat = @"yyyy年M月d日 H点m分";
    NSLog(@"%@", [formatter stringFromDate:dateTime]);
    
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateTime];
	
    int days = ((int)diff)/(3600*24);
    switch (days) {
        case 0:{
            int hours = ((int)diff)%(3600*24)/3600;
            if (hours > 0) {
                formatCreatedTime = [NSString stringWithFormat:@"%d小时前",hours];
            }else{
                int minutes = ((int)diff)%(3600*24)%3600/60;
                if (minutes > 0) {
                    formatCreatedTime = [NSString stringWithFormat:@"%d分钟前", minutes];
                }else{
                    int seconds = ((int)diff)%(3600*24)%3600%60;
                    formatCreatedTime = [NSString stringWithFormat:@"%d秒前", seconds];
                }
            }
            break;
        }
        case 1:
            formatCreatedTime = @"昨天";
            break;
        case 2:
            formatCreatedTime = @"前天";
        default:
            formatter.dateFormat = @"M月d日 H点m分";
            formatCreatedTime = [formatter stringFromDate:dateTime];
            break;
    }
    return formatCreatedTime;
//    int hours = ((int)diff)%(3600*24)/3600;
//    int minutes = ((int)diff)%(3600*24)%3600/60;
//    int seconds = ((int)diff)%(3600*24)%3600%60;
//    NSLog(@"%d天%d小时%d分%d秒", days, hours, minutes, seconds);
}

- (NSString *)formatSource:(NSString *)originalSource
{
    NSString *formatSource;
    NSArray *components = [originalSource componentsSeparatedByString:@">"];
    if (components.count > 1) {
        formatSource = [[[components objectAtIndex:1] componentsSeparatedByString:@"<"] objectAtIndex:0];
    }
    return formatSource;
}

- (NSArray *)formatThumbnails:(NSArray *)originalPicURLs
{
    NSMutableArray *thumbnails = [[NSMutableArray alloc] init];
    for (NSDictionary *picURL in originalPicURLs) {
        NSString *thumbnail = [picURL objectForKey:@"thumbnail_pic"];
        [thumbnails addObject:thumbnail];
    }
    return thumbnails;
}
@end
