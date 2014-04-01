//
//  FHContentImageView.h
//  Weirdo
//
//  Created by FengHuan on 14-4-1.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHContentImageView : UIView

- (void)resetView;
- (void)updateViewWithURLs:(NSArray *)imageURLs;
+ (float)getViewHeightForImageCount:(int)count;
@end
