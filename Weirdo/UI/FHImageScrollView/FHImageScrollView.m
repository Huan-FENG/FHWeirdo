//
//  FHImageScrollView.m
//  Weirdo
//
//  Created by FengHuan on 14-4-14.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHImageScrollView.h"
#import "FHSImageView.h"

@implementation FHImageScrollView
{
    NSArray *imagesArray;
    NSUInteger currentIndex;
    UIScrollView *scrollImageView;
    UILabel *indexLB;
    
    NSMutableArray *imageViews;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        scrollImageView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollImageView setShowsVerticalScrollIndicator:NO];
        [scrollImageView setShowsHorizontalScrollIndicator:NO];
        [scrollImageView setPagingEnabled:YES];
        [scrollImageView setDelegate:self];
        [self addSubview:scrollImageView];
        
        indexLB = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
        [indexLB setBackgroundColor:[UIColor clearColor]];
        [indexLB setTextColor:[UIColor grayColor]];
        [indexLB setShadowColor:[UIColor clearColor]];
        [indexLB setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self addSubview:indexLB];
        
        [self setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tapRecognizer];
        [self setAlpha:0.0];
    }
    return self;
}

- (id)initWithImageURLs:(NSArray *)imageURLs currentIndex:(NSUInteger)index
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        imagesArray = imageURLs;
        currentIndex = index;
        
        [scrollImageView setContentSize:CGSizeMake(scrollImageView.frame.size.width*imageURLs.count, self.frame.size.height)];
        indexLB.text = [NSString stringWithFormat:@"%d/%d", index+1, imageURLs.count];
        
        for (int i = 0; i<imageURLs.count; i++) {
            if (!imageViews) {
                imageViews = [[NSMutableArray alloc] initWithCapacity:9];
            }
            [imageViews addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished){
        if (finished) {
            [self removeFromSuperview];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }];
}

- (void)show
{
    [self loadImageViewForIndex:currentIndex];
    [scrollImageView setContentOffset:CGPointMake(currentIndex*scrollImageView.frame.size.width, 0)];
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished){
        if (finished) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
    }];
}

- (void)loadImageViewForIndex:(NSUInteger)index;
{
    [self loadImageViewAtIndex:index];
    if (index > 0) {
        [self loadImageViewAtIndex:index-1];
    }
    if (index+1<imagesArray.count) {
        [self loadImageViewAtIndex:index+1];
    }
}

- (void)loadImageViewAtIndex:(NSUInteger)index
{
    FHSImageView *imageView = [imageViews objectAtIndex:index];
    if ([imageView isKindOfClass:[NSNull class]]) {
        imageView = [[FHSImageView alloc] initWithImageURL:[imagesArray objectAtIndex:index]];
        CGRect frame = imageView.frame;
        frame.origin.x = index*scrollImageView.frame.size.width;
        [imageView setFrame:frame];
        [scrollImageView addSubview:imageView];
        [imageViews replaceObjectAtIndex:index withObject:imageView];
    }
}

#pragma mark
#pragma mark

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int x = scrollView.contentOffset.x;
    //move to next...
    if(x > currentIndex*scrollImageView.frame.size.width) {
        [self loadImageViewForIndex:currentIndex < imagesArray.count-1? currentIndex+1: currentIndex];
    }else{
        //move to pre...
        [self loadImageViewForIndex:currentIndex>0? currentIndex - 1:0];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    currentIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    indexLB.text = [NSString stringWithFormat:@"%d/%d", currentIndex+1, imagesArray.count];
}

@end
