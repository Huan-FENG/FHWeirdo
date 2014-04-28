//
//  FHScrollImage.m
//  Weirdo
//
//  Created by FengHuan on 14-4-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHScrollImage.h"
#import "FHImageCache.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@implementation FHScrollImage
{
    NSString *loadImageURL;
    UILabel *loadingTipLB;
    YLImageView *imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        imageView = [[YLImageView alloc] initWithFrame:self.bounds];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        loadingTipLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        [loadingTipLB setBackgroundColor:[UIColor blackColor]];
        [loadingTipLB setAlpha:0.8];
        [loadingTipLB setShadowColor:[UIColor clearColor]];
        [loadingTipLB setTextColor:[UIColor whiteColor]];
        [loadingTipLB setFont:[UIFont systemFontOfSize:12.0]];
        loadingTipLB.text = @"加载中...";
        
        [imageView setUserInteractionEnabled:YES];
        [imageView setMultipleTouchEnabled:YES];
        [self addSubview:imageView];
        [self addSubview:loadingTipLB];
        [self setDelegate:self];
    }
    return self;
}

- (id)initWithImageURL:(NSString *)imageURL
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        NSString *sImageURL = imageURL;
        UIImage *image = [[FHImageCache sharedImage] getHighestPxImageForURL:sImageURL];
        if (!image) {
            image = [[FHImageCache sharedImage] getImageForURL:sImageURL];
            if (!image) {
                image = [UIImage imageNamed:@"default_image.png"];
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkImage:) userInfo:sImageURL repeats:YES];
            }
            loadImageURL = [sImageURL stringByReplacingOccurrencesOfString:@"/thumbnail/" withString:@"/large/"];
            [self loadImage];
        }else{
            [loadingTipLB setHidden:YES];
            [self setScrollViewZoomScale];
        }
        [imageView setImage:image];
    }
    return self;
}

- (void)checkImage:(NSTimer *)timer
{
    NSString *checkImageURL = timer.userInfo;
    UIImage *checkImage = [[FHImageCache sharedImage] getHighestPxImageForURL:checkImageURL];
    if (!checkImage) {
        checkImage = [[FHImageCache sharedImage] getImageForURL:checkImageURL];
    }
    if (checkImage) {
        [imageView setImage:checkImage];
        [timer invalidate];
        timer = nil;
    }
}

- (void)loadImage
{
    [loadingTipLB setHidden:NO];
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc] init];
    [property setAfterFinishedSelector:@selector(finishLoadingImage:)];
    [property setAfterFinishedTarget:self];
    [property setProgressSelector:@selector(loadProcessingRate:)];
    [property setProgressTarget:self];
    [property setAfterFailedSelector:@selector(failedLoadingImage:)];
    [property setAfterFailedTarget:self];
    [[FHWeiBoAPI sharedWeiBoAPI] fetchImagesForURL:loadImageURL interactionProperty:property];
}

- (void)failedLoadingImage:(NSError *)error
{
    [loadingTipLB setHidden:NO];
    loadingTipLB.text = error.localizedDescription;
}

- (void)loadProcessingRate:(NSNumber *)rate
{
    float percentage = rate.floatValue * 100;
    loadingTipLB.text = [NSString stringWithFormat:@"(%.2f%%)加载中...", percentage];
}

- (void)finishLoadingImage:(NSData *)imageData
{
    [loadingTipLB setHidden:YES];
    id image;
    if ([loadImageURL.pathExtension isEqualToString:@"gif"]) {
        image = [YLGIFImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    }else
        image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    if (image) {
        [UIView animateWithDuration:0.5 animations:^{
            [imageView setImage:image];
        } completion:^(BOOL finished){
            if (finished) {
                [[FHImageCache sharedImage] cacheImage:image forURL:loadImageURL];
                if (![loadImageURL.pathExtension isEqualToString:@"gif"]) {
                    [self setScrollViewZoomScale];
                }
            }
        }];
    }
}

- (void)setScrollViewZoomScale
{
    [self setMinimumZoomScale:1];
    [self setMaximumZoomScale:15];
}

#pragma mark
#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
}


@end
