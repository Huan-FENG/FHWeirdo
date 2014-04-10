//
//  FHTimelineViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-4-10.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "FHTimelinePostCell.h"
#import "FHTimlineTableViewController.h"

//typedef enum : NSUInteger {
//    TimelineCategoryHome,
//    TimelineCategoryFriends,
//    TimelineCategoryPublic,
//} TimelineCategory;

@interface FHTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, FHTimelinPostCellDelegate>

@property (nonatomic, strong) PullTableView *pullTableView;
@property (nonatomic) TimelineCategory category;

- (id)initWithTimeline:(TimelineCategory)timelineCategory;

@end
