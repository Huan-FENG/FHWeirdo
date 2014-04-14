//
//  FHImageScrollView.h
//  Weirdo
//
//  Created by FengHuan on 14-4-14.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHImageScrollView : UIView <UIScrollViewDelegate>

- (id)initWithImageURLs:(NSArray *)imageURLs currentIndex:(NSUInteger)index;
- (void)show;

@end
