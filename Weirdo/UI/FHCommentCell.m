//
//  FHCommentCell.m
//  Weirdo
//
//  Created by FengHuan on 14-4-9.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHCommentCell.h"
#import "FHUsers.h"

#define PADDING_HORIZON 10.0
#define PADDING_VERTICAL 10.0
#define COMMENT_FONT [UIFont fontWithName:@"Heiti SC" size:12.0]

@implementation FHCommentCell
{
    NSTimer *updateImageTimer;
}
@synthesize userImage, usernameLB, timeLB, commentLB;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_HORIZON, PADDING_HORIZON, 30, 30)];
        [userImage setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
        // add corner and shadow
        userImage.layer.cornerRadius = 10;
        userImage.layer.shadowColor = [UIColor grayColor].CGColor;
        userImage.layer.shadowOpacity = 1.0;
        userImage.layer.shadowRadius = 2.0;
        userImage.layer.shadowOffset = CGSizeMake(0, 0.2);
        
        usernameLB = [[UILabel alloc] initWithFrame:CGRectMake(userImage.frame.origin.x + userImage.frame.size.width+PADDING_HORIZON, userImage.frame.origin.y, 150, 10)];
        [usernameLB setBackgroundColor:[UIColor clearColor]];
        [usernameLB setFont:[UIFont systemFontOfSize:10.0]];
        [usernameLB setTextAlignment:NSTextAlignmentLeft];
        
        timeLB = [[UILabel alloc] initWithFrame:CGRectMake(usernameLB.frame.origin.x+usernameLB.frame.size.width, usernameLB.frame.origin.y, 320-PADDING_HORIZON-usernameLB.frame.origin.x-usernameLB.frame.size.width, usernameLB.frame.size.height)];
        [timeLB setFont:usernameLB.font];
        [timeLB setTextColor:[UIColor lightGrayColor]];
        [timeLB setTextAlignment:NSTextAlignmentRight];
        [timeLB setBackgroundColor:[UIColor clearColor]];
        [timeLB setShadowColor:[UIColor clearColor]];
        
        commentLB = [[RCLabel alloc] initWithFrame:CGRectMake(usernameLB.frame.origin.x, usernameLB.frame.origin.y+usernameLB.frame.size.height+5, 320-3*PADDING_HORIZON-userImage.frame.size.width, 0)];
        [commentLB setFont:COMMENT_FONT];
        [commentLB setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:userImage];
        [self.contentView addSubview:usernameLB];
        [self.contentView addSubview:timeLB];
        [self.contentView addSubview:commentLB];
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

- (void)updateCellWithComment:(FHPost *)comment
{
    FHUser *user = [[FHUsers sharedUsers] getUserForID:comment.userID];
    userImage.image = user.profileImage;
    if (!userImage.image) {
        updateImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUserImage:) userInfo:comment.userID repeats:YES];
    }

    usernameLB.text = comment.username;
    timeLB.text = comment.createdTime;
    
    RCLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:comment.text];
    commentLB.componentsAndPlainText = componentsDS;
    RCLabel *tempLabel = [[RCLabel alloc] initWithFrame:commentLB.frame];
    [tempLabel setFont:COMMENT_FONT];
    tempLabel.componentsAndPlainText = componentsDS;
    CGSize optimalSize = [tempLabel optimumSize:YES];
    CGRect frame = tempLabel.frame;
    frame.size.height = optimalSize.height+1;
    [commentLB optimumSize:YES];
    [commentLB setFrame:frame];

}

+ (float)cellHeightWithComment:(FHPost *)comment
{
    RCLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:comment.text];
    RCLabel *tempLabel = [[RCLabel alloc] initWithFrame:CGRectMake(0, 0, 320-3*PADDING_HORIZON-30, 0)];
    [tempLabel setFont:COMMENT_FONT];
    tempLabel.componentsAndPlainText = componentsDS;
    CGSize commentSize = [tempLabel optimumSize:YES];

    float height = PADDING_VERTICAL*2 + 15 +commentSize.height+1;
    if (height < 2*PADDING_VERTICAL + 30) {
        height = 2*PADDING_VERTICAL + 30;
    }
    return height;
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

@end
