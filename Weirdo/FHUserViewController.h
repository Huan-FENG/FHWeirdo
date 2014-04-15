//
//  FHUserViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-4-15.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHTimelinePostCell.h"

@interface FHUserViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, FHTimelinPostCellDelegate>

- (id)initWithUserID:(NSString *)userID;

@end
