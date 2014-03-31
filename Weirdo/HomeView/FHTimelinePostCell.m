//
//  FHTimelinePostCell.m
//  Weirdo
//
//  Created by FengHuan on 14-3-31.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHTimelinePostCell.h"
#import "FHUsers.h"

@implementation FHTimelinePostCell
{
    NSTimer *updateImageTimer;
}

@synthesize userImage, userNameLB, timeLB;
@synthesize content;
@synthesize fromLB, voteCountLB, retweetCountLB, commentCountLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 30, 30)];
        [userImage setBackgroundColor:[UIColor colorWithRed:210 green:215 blue:210 alpha:1.0]];
        
        userNameLB = [[UILabel alloc] initWithFrame:CGRectMake(40, userImage.frame.origin.y, 275, 20)];
        [userNameLB setTextAlignment:NSTextAlignmentLeft];
        [userNameLB setFont:[UIFont boldSystemFontOfSize:12]];
        [userNameLB setTextColor:[UIColor brownColor]];
        [userNameLB setContentMode:UIViewContentModeBottom];
        [userNameLB setBackgroundColor:[UIColor clearColor]];
        timeLB = [[UILabel alloc] initWithFrame:CGRectMake(userNameLB.frame.origin.x, userNameLB.frame.origin.y + userNameLB.frame.size.height, 50, userImage.frame.size.height - userNameLB.frame.size.height)];
        [timeLB setContentMode:UIViewContentModeBottom];
        [timeLB setTextAlignment:NSTextAlignmentLeft];
        [timeLB setFont:[UIFont systemFontOfSize:9]];
        [timeLB setTextColor:[UIColor grayColor]];
        [timeLB setBackgroundColor:[UIColor clearColor]];
        
        fromLB = [[UILabel alloc] initWithFrame:CGRectMake(timeLB.frame.origin.x + timeLB.frame.size.width, timeLB.frame.origin.y, 275 - timeLB.frame.size.width, timeLB.frame.size.height)];
        [fromLB setContentMode:UIViewContentModeBottom];
        [fromLB setTextAlignment:NSTextAlignmentLeft];
        [fromLB setFont:timeLB.font];
        [fromLB setTextColor:[UIColor grayColor]];
        [fromLB setBackgroundColor:[UIColor clearColor]];
        
        content = [[UILabel alloc] initWithFrame:CGRectZero];
        [content setNumberOfLines:0];
        [content setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [content setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:userImage];
        [self.contentView addSubview:userNameLB];
        [self.contentView addSubview:timeLB];
        [self.contentView addSubview:fromLB];
        [self.contentView addSubview:content];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUserImage:(NSTimer *)timer
{
    FHUser *user = timer.userInfo;
    userImage.image = user.profileImage;
    if (userImage.image) {
        [updateImageTimer invalidate];
    }
}

- (void)updateCellWithPost:(FHPost *)post
{
    FHUser *user = [[FHUsers sharedUsers] getUserForID:post.userID];
    userImage.image = user.profileImage;
    if (!userImage.image) {
        updateImageTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateUserImage:) userInfo:user repeats:YES];
    }
    
    userNameLB.text = post.username;
    timeLB.text = post.createdTime;
    fromLB.text = post.source;
    content.text = post.text;
    [content setFrame:CGRectMake(userImage.frame.origin.x, userImage.frame.origin.y + userImage.frame.size.height + 5, 310, 80)];
    [content sizeToFit];
}

+ (float)cellHeightWithPost:(FHPost *)post
{
    CGSize constraintSize = CGSizeMake(310, MAXFLOAT);
    CGSize contentSize = [post.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    float height = 10 + 30 + 5 + contentSize.height + 10;
    return height;
}

@end
