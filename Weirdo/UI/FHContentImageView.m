//
//  FHContentImageView.m
//  Weirdo
//
//  Created by FengHuan on 14-4-1.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHContentImageView.h"
#import "FHImageView.h"

#define CONTENT_MULTI_IMAGE_VIEW_HIGHT 80
#define PADDING 5
#define CONTENT_SINGLE_IMAGE_HIGHT 100

@implementation FHContentImageView
{
    NSOperationQueue *downloadImageQueue;
    NSArray *contentImageURLs;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)resetView
{
    [self setFrame:CGRectZero];
    for (id sub in self.subviews) {
        [sub removeFromSuperview];
    }
}
- (void)updateViewWithURLs:(NSArray *)imageURLs
{
    [self resetView];
    if (!downloadImageQueue) {
        downloadImageQueue = [[NSOperationQueue alloc] init];
        [downloadImageQueue setMaxConcurrentOperationCount:1.0];
    }
    float height = [FHContentImageView getViewHeightForImageCount:imageURLs.count];
    if (imageURLs.count == 1) {
        [self setFrame:CGRectMake(0, 0, height, height)];
        FHImageView *imageView = [[FHImageView alloc] initWithFrame:self.frame];
        [imageView setNeedScale:YES];
        [imageView setScaleSize:CGSizeMake(0, CONTENT_SINGLE_IMAGE_HIGHT)];
        [imageView loadImageForURL:[imageURLs objectAtIndex:0]];
        [self addSubview:imageView];
    }else{
        [self setFrame:CGRectMake(0, 0, PADDING + (PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT) * 3, height)];
        for (int i = 0; i<imageURLs.count; i++) {
            int row = i/3;
            int column = i%3;
            FHImageView *imageView = [[FHImageView alloc] initWithFrame:CGRectMake(PADDING + (PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT)*column, ( PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT)*row, CONTENT_MULTI_IMAGE_VIEW_HIGHT, CONTENT_MULTI_IMAGE_VIEW_HIGHT)];
            [imageView loadImageForURL:[imageURLs objectAtIndex:i]];
            [self addSubview:imageView];
        }
    }
}

+ (float)getViewHeightForImageCount:(int)count
{
    float height = 0.0;
    int rows =  (count - 1)/3 + 1;
    switch (rows) {
        case 1:
            if (count == 1) {
                height = CONTENT_SINGLE_IMAGE_HIGHT;
            }else
                height = CONTENT_MULTI_IMAGE_VIEW_HIGHT;
            break;
        case 2:
        case 3:
            height = (PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT) * rows - PADDING;
            break;
        default:
            break;
    }
    return height;

}

@end
