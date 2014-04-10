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
    UIImageView *detailView;
    UILabel *retweetCountLB;
    UILabel *commentCountLB;
    UILabel *voteCountLB;
}

#define PADDING_HORIZON 10.0
#define PADDING_VERTICAL 10.0
#define PADDING_RETWEET 15.0
#define FONT [UIFont fontWithName:@"Heiti SC" size:15.0]
#define FONT_SIZE 15.0
#define USERIMAGE_WIDTH 30.0
#define DETAIL_VIEW_HIEIGHT 30

@synthesize userImage, userNameLB, timeLB;
@synthesize content, retweetContent, retweetStatusBackground, contentImageView;
@synthesize fromLB, voteCountLB, retweetCountLB, commentCountLB;
@synthesize indexPath, delegate;

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
        [userNameLB setBackgroundColor: [UIColor clearColor]];
        
        timeLB = [[UILabel alloc] initWithFrame:CGRectMake(userNameLB.frame.origin.x, userNameLB.frame.origin.y + userNameLB.frame.size.height, 50, userImage.frame.size.height - userNameLB.frame.size.height)];
        [timeLB setContentMode:UIViewContentModeBottom];
        [timeLB setTextAlignment:NSTextAlignmentLeft];
        [timeLB setFont:[UIFont systemFontOfSize:9]];
        [timeLB setTextColor:[UIColor grayColor]];
        [timeLB setBackgroundColor: [UIColor clearColor]];
        [timeLB setShadowColor:[UIColor clearColor]];
        
        fromLB = [[UILabel alloc] initWithFrame:CGRectMake(timeLB.frame.origin.x + timeLB.frame.size.width, timeLB.frame.origin.y, userNameLB.frame.size.width - timeLB.frame.size.width, timeLB.frame.size.height)];
        [fromLB setContentMode:UIViewContentModeBottom];
        [fromLB setTextAlignment:NSTextAlignmentLeft];
        [fromLB setFont:timeLB.font];
        [fromLB setTextColor:[UIColor grayColor]];
        [fromLB setBackgroundColor: [UIColor clearColor]];
        [fromLB setShadowColor:[UIColor clearColor]];
        
        content = [[RCLabel alloc] initWithFrame:CGRectZero];
        [content setFont:FONT];
        [content setBackgroundColor:[UIColor clearColor]];
        
        contentImageView = [[FHContentImageView alloc] initWithFrame:CGRectZero];
        [contentImageView setDelegate:self];
        
        retweetStatusBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
        [retweetStatusBackground setImage:[[UIImage imageNamed:@"timeline_rt_border.png"] stretchableImageWithLeftCapWidth:130 topCapHeight:14]];
        
        retweetContent = [[RCLabel alloc] initWithFrame:CGRectZero];
        [retweetContent setFont:content.font];
        [retweetContent setBackgroundColor:[UIColor clearColor]];
        
        detailView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_HORIZON, 0, 320-2*PADDING_HORIZON, DETAIL_VIEW_HIEIGHT)];
        [detailView setImage:[[UIImage imageNamed:@"timeline_detail_border.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5]];
        [detailView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *detailViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailViewClicked:)];
        [detailView addGestureRecognizer:detailViewTap];
        
        UIImageView *retweetCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, detailView.frame.size.width/3/2-5, detailView.frame.size.height)];
        [retweetCountIcon setImage:[UIImage imageNamed:@"timeline_retweet_count_icon.png"]];
        [retweetCountIcon setContentMode:UIViewContentModeRight];
        [retweetCountIcon setUserInteractionEnabled:YES];
        [detailView addSubview:retweetCountIcon];
        retweetCountLB = [[UILabel alloc] initWithFrame:CGRectMake(retweetCountIcon.frame.size.width+5, 0, retweetCountIcon.frame.size.width, retweetCountIcon.frame.size.height)];
        [retweetCountLB setUserInteractionEnabled:YES];
        [retweetCountLB setTextAlignment:NSTextAlignmentLeft];
        [retweetCountLB setFont:[UIFont systemFontOfSize:10]];
        [retweetCountLB setTextColor:[UIColor colorWithRed:105.0/255.0 green:150.0/255.0 blue:180.0/255.0 alpha:1.0]];
        [retweetCountLB setBackgroundColor:[UIColor clearColor]];
        [detailView addSubview:retweetCountLB];
        
        UIImageView *commentCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(retweetCountLB.frame.origin.x+retweetCountLB.frame.size.width, 0, retweetCountIcon.frame.size.width, detailView.frame.size.height)];
        [commentCountIcon setImage:[UIImage imageNamed:@"timeline_comment_count_icon.png"]];
        [commentCountIcon setContentMode:UIViewContentModeRight];
        [detailView addSubview:commentCountIcon];
        commentCountLB = [[UILabel alloc] initWithFrame:CGRectMake(commentCountIcon.frame.origin.x+commentCountIcon.frame.size.width+5, 0, retweetCountLB.frame.size.width, commentCountIcon.frame.size.height)];
        [commentCountLB setFont:retweetCountLB.font];
        [commentCountLB setTextColor:retweetCountLB.textColor];
        [commentCountLB setTextAlignment:NSTextAlignmentLeft];
        [commentCountLB setUserInteractionEnabled:YES];
        [commentCountLB setBackgroundColor: [UIColor clearColor]];
        [detailView addSubview:commentCountLB];
        
        UIImageView *voteCountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(commentCountLB.frame.origin.x+commentCountLB.frame.size.width, 0, commentCountIcon.frame.size.width, detailView.frame.size.height)];
        [voteCountIcon setImage:[UIImage imageNamed:@"timeline_comment_count_icon.png"]];
        [voteCountIcon setContentMode:UIViewContentModeRight];
        [detailView addSubview:voteCountIcon];
        voteCountLB = [[UILabel alloc] initWithFrame:CGRectMake(voteCountIcon.frame.origin.x+voteCountIcon.frame.size.width+5, 0, commentCountLB.frame.size.width, voteCountIcon.frame.size.height)];
        [voteCountLB setTextAlignment:NSTextAlignmentLeft];
        [voteCountLB setFont:commentCountLB.font];
        [voteCountLB setTextColor:commentCountLB.textColor];
        [voteCountLB setBackgroundColor:[UIColor clearColor]];
        [detailView addSubview:voteCountLB];
        
        [self.contentView addSubview:userImage];
        [self.contentView addSubview:userNameLB];
        [self.contentView addSubview:timeLB];
        [self.contentView addSubview:fromLB];
        [self.contentView addSubview:content];
        [self.contentView addSubview:retweetStatusBackground];
        [self.contentView addSubview:retweetContent];
        [self.contentView addSubview:contentImageView];
        [self.contentView addSubview:detailView];
    }
    return self;
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

- (void)updateCellWithPost:(FHPost *)post isPostOnly:(BOOL)postOnly
{
    FHUser *user = [[FHUsers sharedUsers] getUserForID:post.userID];
    userImage.image = user.profileImage;
    if (!userImage.image) {
        updateImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUserImage:) userInfo:post.userID repeats:YES];
    }
    
    userNameLB.text = post.username;
    timeLB.text = post.createdTime;
    fromLB.text = post.source;
    
    RCLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:post.text];
//    cell.RCLabel.delegate=self;
    content.componentsAndPlainText = componentsDS;
    RCLabel *tempLabel = [[RCLabel alloc] initWithFrame:CGRectMake(userImage.frame.origin.x, userImage.frame.origin.y + userImage.frame.size.height + PADDING_VERTICAL, 320 - 2*PADDING_HORIZON, 80)];
    [tempLabel setFont:FONT];
    tempLabel.componentsAndPlainText = componentsDS;
    CGSize optimalSize = [tempLabel optimumSize:YES];
    CGRect frame = tempLabel.frame;
    frame.size.height = optimalSize.height+1;
    [content optimumSize:YES];
    [content setFrame:frame];
//    [content setBackgroundColor:[UIColor yellowColor]];
    
    CGRect detailViewFrame = detailView.frame;
    detailViewFrame.origin.y = content.frame.origin.y + content.frame.size.height +PADDING_VERTICAL/2;
    if (post.picURLs && post.picURLs.count > 0) {
        [contentImageView updateViewWithURLs:post.picURLs];
        contentImageView.center = self.contentView.center;
        CGRect frame = contentImageView.frame;
        frame.origin.y = content.frame.origin.y + content.frame.size.height + PADDING_VERTICAL;
        [contentImageView setFrame:frame];
        detailViewFrame.origin.y = contentImageView.frame.origin.y + contentImageView.frame.size.height + PADDING_VERTICAL/2;
        
    }else{
        [contentImageView resetView];
    }
    
    if (post.retweeted) {
        FHPost *retweeted = post.retweeted;
        NSString *retweetContentText = [NSString stringWithFormat:@"@%@:%@", retweeted.username, retweeted.text];
        RCLabelComponentsStructure *retweetComponentsDS = [RCLabel extractTextStyle:retweetContentText];
        retweetContent.componentsAndPlainText = retweetComponentsDS;
        RCLabel *retweetTempLabel = [[RCLabel alloc] initWithFrame:CGRectMake(PADDING_RETWEET, content.frame.origin.y + content.frame.size.height + PADDING_VERTICAL, 320-2*PADDING_RETWEET, 80)];
        [retweetTempLabel setFont:FONT];
        retweetTempLabel.componentsAndPlainText = retweetComponentsDS;
        CGSize retweetOptimalSize = [retweetTempLabel optimumSize:YES];
        CGRect retweetFrame = retweetTempLabel.frame;
        retweetFrame.size.height = retweetOptimalSize.height+1;
        [retweetContent optimumSize:YES];
        [retweetContent setFrame:retweetFrame];
//        [retweetContent setBackgroundColor:[UIColor clearColor]];
        
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
        detailViewFrame.origin.y = retweetStatusBackground.frame.origin.y + retweetStatusBackground.frame.size.height + PADDING_VERTICAL/2;
    }else{
        retweetContent.componentsAndPlainText = nil;
        [retweetContent setFrame:CGRectZero];
        [retweetStatusBackground setFrame:CGRectZero];
    }
    
    if (!postOnly) {
        [detailView setFrame:detailViewFrame];
        retweetCountLB.text = post.reporstsCount.intValue != 0?[NSString stringWithFormat:@"(%d)",post.reporstsCount.intValue]: @"转发";
        commentCountLB.text = post.commentsCount.intValue != 0?[NSString stringWithFormat:@"(%d)",post.commentsCount.intValue]: @"评论";
        voteCountLB.text = post.voteCounts.intValue != 0?[NSString stringWithFormat:@"(%d)",post.voteCounts.intValue]: @"赞";
    }else{
        [detailView removeFromSuperview];
    }
}

+ (float)cellHeightWithPost:(FHPost *)post isPostOnly:(BOOL)postOnly
{
    RCLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:post.text];
    RCLabel *tempLabel = [[RCLabel alloc] initWithFrame:CGRectMake(0, 0, 320 - 2*PADDING_HORIZON, 80)];
    [tempLabel setFont:FONT];
    tempLabel.componentsAndPlainText = componentsDS;
    CGSize optimalSize = [tempLabel optimumSize:YES];
    CGSize contentSize = CGSizeMake(0, optimalSize.height+1);

    float height = PADDING_VERTICAL + USERIMAGE_WIDTH + PADDING_VERTICAL + contentSize.height;
    if (post.picURLs && post.picURLs.count>0) {
        height = height + PADDING_VERTICAL + [FHContentImageView getViewHeightForImageCount:post.picURLs.count];
    }
    if (post.retweeted)
    {
        RCLabelComponentsStructure *rComponentsDS = [RCLabel extractTextStyle:[NSString stringWithFormat:@"@%@:%@", post.retweeted.username, post.retweeted.text]];
        RCLabel *rTempLabel = [[RCLabel alloc] initWithFrame:CGRectMake(0, 0, 320 - 2*PADDING_HORIZON, 80)];
        [rTempLabel setFont:FONT];
        rTempLabel.componentsAndPlainText = rComponentsDS;
        CGSize rOptimalSize = [rTempLabel optimumSize:YES];
        CGSize retweetedContentSize = CGSizeMake(0, rOptimalSize.height+1);
        
        height = height + PADDING_VERTICAL + retweetedContentSize.height;
        
        if (post.retweeted.picURLs && post.retweeted.picURLs.count>0) {
            height = height + PADDING_VERTICAL + [FHContentImageView getViewHeightForImageCount:post.retweeted.picURLs.count];
        }
        height = height + PADDING_VERTICAL;
    }
    
    if (!postOnly) {
        height = height + PADDING_VERTICAL/2 + DETAIL_VIEW_HIEIGHT;
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

- (void)detailViewClicked:(UITapGestureRecognizer *)sender
{
    CellClickedType clickedType;
    CGPoint touchLocation = [sender locationInView:detailView];
    if (touchLocation.x < 320/3) {
        clickedType = CellClickedTypeRetweet;
    }else if(touchLocation.x <320/3*2){
        clickedType = CellClickedTypeComment;
    }else{
        clickedType = CellClickedTypeVote;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelinePostCell:didSelectAtIndexPath:withClickedType:contentIndex:)]) {
        [self.delegate timelinePostCell:self didSelectAtIndexPath:self.indexPath withClickedType:clickedType contentIndex:0];
    }
}

#pragma mark
#pragma mark - contentImageView delegate

- (void)contentImageView:(FHContentImageView *)contentImageView didSelectAtIndex:(NSUInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timelinePostCell:didSelectAtIndexPath:withClickedType:contentIndex:)]) {
        [self.delegate timelinePostCell:self didSelectAtIndexPath:self.indexPath withClickedType:CellClickedTypePictures contentIndex:index];
    }
}

@end
