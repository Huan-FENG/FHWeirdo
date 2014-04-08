//
//  FHTimlineTableViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHTimelinePostCell.h"

typedef enum : NSUInteger {
    TimelineCategoryHome,
    TimelineCategoryFriends,
    TimelineCategoryPublic,
} TimelineCategory;

@interface FHTimlineTableViewController : UITableViewController <FHTimelinPostCellDelegate>

@property (nonatomic) TimelineCategory category;

- (id)initWithTimeline:(TimelineCategory)timelineCategory;

@end
