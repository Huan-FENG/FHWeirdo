//
//  FHTimelinePostCell.h
//  Weirdo
//
//  Created by FengHuan on 14-3-31.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHContentImageView.h"

@interface FHTimelinePostCell : UITableViewCell

@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *userNameLB;
@property (strong, nonatomic) UILabel *timeLB;
@property (strong, nonatomic) UILabel *fromLB;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) FHContentImageView *contentImageView;
@property (strong, nonatomic) UILabel *voteCountLB;
@property (strong, nonatomic) UILabel *retweetCountLB;
@property (strong, nonatomic) UILabel *commentCountLB;

- (void)updateCellWithPost:(FHPost *)post;
+ (float)cellHeightWithPost:(FHPost *)post;

@end
