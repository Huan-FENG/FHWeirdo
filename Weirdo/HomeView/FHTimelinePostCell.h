//
//  FHTimelinePostCell.h
//  Weirdo
//
//  Created by FengHuan on 14-3-31.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHContentImageView.h"
//#import "FHTweetLabel.h"
#import "RCLabel.h"

@class FHTimelinePostCell;

typedef enum : NSUInteger {
    CellClickedTypePictures,
    CellClickedTypeRetweet,
    CellClickedTypeComment,
    CellClickedTypeVote,
    CellClickedTypeUserImage,
} CellClickedType;

@protocol FHTimelinPostCellDelegate <NSObject>

@optional
- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectAtIndexPath:(NSIndexPath *)indexPath withClickedType:(CellClickedType)clickedType contentIndex:(NSUInteger)index;
- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectLink:(NSString *)link;

@end

@interface FHTimelinePostCell : UITableViewCell <FHContentImageViewDelegate, RCLabelDelegate>

@property (strong, nonatomic) UIImageView *userImage;
@property (strong, nonatomic) UILabel *userNameLB;
@property (strong, nonatomic) UILabel *timeLB;
@property (strong, nonatomic) UILabel *fromLB;
@property (nonatomic, strong) RCLabel *content;
@property (nonatomic, strong) UIImageView *retweetStatusBackground;
@property (nonatomic, strong) RCLabel *retweetContent;
@property (nonatomic, strong) FHContentImageView *contentImageView;
@property (strong, nonatomic) UILabel *voteCountLB;
@property (strong, nonatomic) UILabel *retweetCountLB;
@property (strong, nonatomic) UILabel *commentCountLB;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) id<FHTimelinPostCellDelegate> delegate;

- (void)updateCellWithPost:(FHPost *)post isPostOnly:(BOOL)postOnly;
+ (float)cellHeightWithPost:(FHPost *)post isPostOnly:(BOOL)postOnly;

@end
