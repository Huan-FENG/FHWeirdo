//
//  FHSImageView.m
//  Weirdo
//
//  Created by FengHuan on 14-4-14.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHSImageView.h"
#import "FHImageCache.h"

@implementation FHSImageView
{
    NSString *loadImageURL;
    UILabel *loadingTipLB;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        loadingTipLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 30)];
        [loadingTipLB setBackgroundColor:[UIColor blackColor]];
        [loadingTipLB setAlpha:0.8];
        [loadingTipLB setShadowColor:[UIColor clearColor]];
        [loadingTipLB setTextColor:[UIColor whiteColor]];
        [loadingTipLB setFont:[UIFont systemFontOfSize:12.0]];
        loadingTipLB.text = @"加载中...";
        [self addSubview:loadingTipLB];
    }
    return self;
}

- (id)initWithImageURL:(NSString *)imageURL
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        NSString *sImageURL = imageURL;
        NSString *lImageURL = [imageURL stringByReplacingOccurrencesOfString:@"/thumbnail/" withString:@"/large/"];
        
        UIImage *image;
        image = [[FHImageCache sharedImage] getImageForURL:lImageURL];
        if (!image) {
            image = [[FHImageCache sharedImage] getImageForURL:sImageURL];
            if (!image) {
//                image = @"defaul.png";
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkImage:) userInfo:sImageURL repeats:YES];
            }
            loadImageURL = lImageURL;
            [self loadImage];
        }else
            [loadingTipLB setHidden:YES];
        [self setImage:image];
    }
    return self;
}

- (void)checkImage:(NSTimer *)timer
{
    NSString *checkImageURL = timer.userInfo;
    UIImage *checkImage = [[FHImageCache sharedImage] getImageForURL:checkImageURL];
    if (!checkImage) {
        checkImage = [[FHImageCache sharedImage] getImageForURL:loadImageURL];
    }
    if (checkImage) {
        [self setImage:checkImage];
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
    UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    if (image) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setImage:image];
        } completion:^(BOOL finished){
            if (finished) {
                [[FHImageCache sharedImage] cacheImage:image forURL:loadImageURL];
            }
        }];
    }
}

@end
