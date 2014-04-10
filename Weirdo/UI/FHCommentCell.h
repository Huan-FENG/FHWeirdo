//
//  FHCommentCell.h
//  Weirdo
//
//  Created by FengHuan on 14-4-9.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLabel.h"
//#import "FHTweetLabel.h"

@interface FHCommentCell : UITableViewCell

@property (nonatomic) UIImageView *userImage;
@property (nonatomic) UILabel *usernameLB;
//@property (nonatomic) FHTweetLabel *commentLB;
@property (nonatomic) RCLabel *commentLB;
@property (nonatomic) UILabel *timeLB;

- (void)updateCellWithComment:(FHPost *)comment;
+ (float)cellHeightWithComment:(FHPost *)comment;

@end
