//
//  FHPostViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-4-9.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHPostViewController : UITableViewController <UIScrollViewDelegate>

@property (nonatomic) UIView *postView;
@property (nonatomic) FHPost *post;

@end
