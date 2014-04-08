//
//  FHContentImageView.h
//  Weirdo
//
//  Created by FengHuan on 14-4-1.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FHContentImageView;

@protocol FHContentImageViewDelegate <NSObject>

@optional
- (void)contentImageView:(FHContentImageView *)contentImageView didSelectAtIndex:(NSUInteger)index;

@end

@interface FHContentImageView : UIView

@property (strong, nonatomic) id<FHContentImageViewDelegate> delegate;

- (void)resetView;
- (void)updateViewWithURLs:(NSArray *)imageURLs;
+ (float)getViewHeightForImageCount:(int)count;
@end
