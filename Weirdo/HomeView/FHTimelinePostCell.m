//
//  FHTimelinePostCell.m
//  Weirdo
//
//  Created by FengHuan on 14-3-31.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHTimelinePostCell.h"
#import "FHUsers.h"
#import <QuartzCore/QuartzCore.h>

@implementation FHTimelinePostCell
{
    NSTimer *updateImageTimer;
}

#define PADDING_HORIZON 10.0
#define PADDING_VERTICAL 10.0
#define PADDING_RETWEET 15.0
#define FONT [UIFont fontWithName:@"Heiti SC" size:15.0]
#define FONT_SIZE 15.0
#define USERIMAGE_WIDTH 30.0

@synthesize userImage, userNameLB, timeLB;
@synthesize content, retweetContent, retweetStatusBackground, contentImageView;
@synthesize fromLB, voteCountLB, retweetCountLB, commentCountLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_HORIZON, PADDING_VERTICAL, USERIMAGE_WIDTH, USERIMAGE_WIDTH)];
        [userImage setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
        // add corner and shadow
        userImage.layer.cornerRadius = 10;
        userImage.layer.shadowColor = [UIColor grayColor].CGColor;
        userImage.layer.shadowOpacity = 1.0;
        userImage.layer.shadowRadius = 2.0;
        userImage.layer.shadowOffset = CGSizeMake(0, 0.5);
        
        userNameLB = [[UILabel alloc] initWithFrame:CGRectMake(2*PADDING_HORIZON + userImage.frame.size.width, userImage.frame.origin.y, 320 - 3*PADDING_HORIZON - userImage.frame.size.width, 20)];
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
        
        fromLB = [[UILabel alloc] initWithFrame:CGRectMake(timeLB.frame.origin.x + timeLB.frame.size.width, timeLB.frame.origin.y, userNameLB.frame.size.width - timeLB.frame.size.width, timeLB.frame.size.height)];
        [fromLB setContentMode:UIViewContentModeBottom];
        [fromLB setTextAlignment:NSTextAlignmentLeft];
        [fromLB setFont:timeLB.font];
        [fromLB setTextColor:[UIColor grayColor]];
        [fromLB setBackgroundColor:[UIColor clearColor]];
        
        content = [[FHTweetLabel alloc] initWithFrame:CGRectZero];
        [content setNumberOfLines:0];
        [content setFont:FONT];
        [content setBackgroundColor:[UIColor clearColor]];
        
        contentImageView = [[FHContentImageView alloc] initWithFrame:CGRectZero];
        retweetStatusBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
        [retweetStatusBackground setImage:[[UIImage imageNamed:@"timeline_rt_border.png"] stretchableImageWithLeftCapWidth:130 topCapHeight:14]];
        
        retweetContent = [[FHTweetLabel alloc] initWithFrame:CGRectZero];
        [retweetContent setNumberOfLines:0];
        [retweetContent setFont:content.font];
        [retweetContent setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:userImage];
        [self.contentView addSubview:userNameLB];
        [self.contentView addSubview:timeLB];
        [self.contentView addSubview:fromLB];
        [self.contentView addSubview:content];
        [self.contentView addSubview:retweetStatusBackground];
        [self.contentView addSubview:retweetContent];
        [self.contentView addSubview:contentImageView];
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
    NSString *userID = timer.userInfo;
    FHUser *user = [[FHUsers sharedUsers] getUserForID:userID];
    if (user.profileImage) {
        [updateImageTimer invalidate];
        updateImageTimer = nil;
        [userImage setAlpha:0.0];
        userImage.image = user.profileImage;
        [UIView animateWithDuration:0.5 animations:^{
            [userImage setAlpha:1.0];
        } completion:NULL];
    }
}

- (void)updateCellWithPost:(FHPost *)post
{
    FHUser *user = [[FHUsers sharedUsers] getUserForID:post.userID];
    userImage.image = user.profileImage;
    if (!userImage.image) {
        updateImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUserImage:) userInfo:post.userID repeats:YES];
    }
    
    userNameLB.text = post.username;
    timeLB.text = post.createdTime;
    fromLB.text = post.source;
    content.text = post.text;
    
    [content setFrame:CGRectMake(userImage.frame.origin.x, userImage.frame.origin.y + userImage.frame.size.height + PADDING_VERTICAL, 320 - 2*PADDING_HORIZON, 80)];
    [content sizeToFit];
    
    if (post.picURLs && post.picURLs.count > 0) {
        [contentImageView updateViewWithURLs:post.picURLs];
        contentImageView.center = self.contentView.center;
        CGRect frame = contentImageView.frame;
        frame.origin.y = content.frame.origin.y + content.frame.size.height + PADDING_VERTICAL;
        [contentImageView setFrame:frame];
    }else{
        [contentImageView resetView];
    }
    
    if (post.retweeted) {
        FHPost *retweeted = post.retweeted;
        retweetContent.text = [NSString stringWithFormat:@"@%@:%@", retweeted.username, retweeted.text];

        [retweetContent setFrame:CGRectMake(PADDING_RETWEET, content.frame.origin.y + content.frame.size.height + PADDING_VERTICAL, 320-2*PADDING_RETWEET, 80)];
        [retweetContent sizeToFit];
        
        if (retweeted.picURLs && retweeted.picURLs.count > 0) {
            [contentImageView updateViewWithURLs:retweeted.picURLs];
            contentImageView.center = self.contentView.center;
            CGRect frame = contentImageView.frame;
            frame.origin.y = retweetContent.frame.origin.y + retweetContent.frame.size.height + PADDING_VERTICAL;
            [contentImageView setFrame:frame];
        }else{
            [contentImageView resetView];
        }
        
        [retweetStatusBackground setFrame:CGRectMake(0, retweetContent.frame.origin.y - PADDING_VERTICAL, 320, retweetContent.frame.size.height + contentImageView.frame.size.height + PADDING_VERTICAL*2 + (contentImageView.frame.size.height == 0?0:PADDING_VERTICAL))];
    }else{
        retweetContent.text = nil;
        [retweetContent sizeToFit];
        [retweetStatusBackground setFrame:CGRectZero];
    }
}

+ (float)cellHeightWithPost:(FHPost *)post
{
    CGSize contentSize = [FHTweetLabel sizeOfText:post.text withFont:FONT constarintToWidth:320-2*PADDING_HORIZON];
    float height = PADDING_VERTICAL + USERIMAGE_WIDTH + PADDING_VERTICAL + contentSize.height;
    if (post.picURLs && post.picURLs.count>0) {
        height = height + PADDING_VERTICAL + [FHContentImageView getViewHeightForImageCount:post.picURLs.count];
    }
    if (post.retweeted)
    {
        CGSize retweetedContentSize = [FHTweetLabel sizeOfText:[NSString stringWithFormat:@"@%@:%@", post.retweeted.username, post.retweeted.text] withFont:FONT constarintToWidth:320-2*PADDING_RETWEET];
        height = height + PADDING_VERTICAL + retweetedContentSize.height;
        
        if (post.retweeted.picURLs && post.retweeted.picURLs.count>0) {
            height = height + PADDING_VERTICAL + [FHContentImageView getViewHeightForImageCount:post.retweeted.picURLs.count];
        }
        height = height + PADDING_VERTICAL;
    }
    height = height + PADDING_VERTICAL;
    return height;
}

-(void)twitterAccountClicked:(NSString *)link
{
    DLog(@"accountClicked:%@", link);
}

- (void)twitterHashtagClicked:(NSString *)link
{
    DLog(@"tagClicked:%@", link);
}

- (void)websiteClicked:(NSString *)link
{
    DLog(@"websiteClicked:%@", link);
}

@end
