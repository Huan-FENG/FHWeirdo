//
//  FHTimelinePostCell.h
//  Weirdo
//
//  Created by FengHuan on 14-3-31.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_VIEW_HEIGHT 80.0f
#define PADDING_TOP 8.0
#define PADDING_LEFT 8.0
#define FONT_SIZE 15.0

@interface FHTimelinePostCell : UITableViewCell

@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *userNameLB;
@property (strong, nonatomic) UILabel *timeLB;
@property (nonatomic, strong) UILabel *content;
@property (strong, nonatomic) UILabel *fromLB;
@property (strong, nonatomic) UILabel *voteCountLB;
@property (strong, nonatomic) UILabel *retweetCountLB;
@property (strong, nonatomic) UILabel *commentCountLB;

- (void)updateCellWithPost:(FHPost *)post;
+ (float)cellHeightWithPost:(FHPost *)post;

@end
