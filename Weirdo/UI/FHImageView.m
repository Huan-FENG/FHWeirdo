//
//  FHImageView.m
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHImageView.h"
#import "FHImageCache.h"

@implementation FHImageView
{
    NSString *imageURLString;
}

@synthesize needScale, scaleSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
        needScale = NO;
        scaleSize = CGSizeZero;
    }
    return self;
}

- (void)loadImageForURL:(NSString *)URLString
{
    imageURLString = URLString;
    UIImage *image = [[FHImageCache sharedImage] getImageForURL:imageURLString];
    if (!image) {
        FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc] init];
        [property setAfterFinishedSelector:@selector(finishLoadingImage:)];
        [property setAfterFinishedTarget:self];
        [[FHWeiBoAPI sharedWeiBoAPI] fetchImagesForURL:URLString interactionProperty:property];
    }else{
        [self loadImage:image animation:NO];
    }
}

- (void)loadImage:(UIImage *)image animation:(BOOL)animation
{
    if (needScale) {
        image = [self imageWithImage:image];
        if (image.size.width > image.size.height) {
            [self setContentMode:UIViewContentModeScaleAspectFill];
        }else
            [self setContentMode:UIViewContentModeScaleAspectFit];
        [self setClipsToBounds:NO];
    }else{
        [self setContentMode:UIViewContentModeScaleAspectFill];
        [self setClipsToBounds:YES];
    }
    [[FHImageCache sharedImage] cacheImage:image forURL:imageURLString];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setImage:image];
        [self setBackgroundColor:[UIColor clearColor]];
        if (animation) {
            [self setAlpha:0.0];
            [UIView animateWithDuration:0.5 animations:^(void){
                [self setAlpha:1.0];
            }];
        }
    });
}

- (void)finishLoadingImage:(NSData *)imageData
{
    UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    if (image) {
        [self loadImage:image animation:YES];
    }
}

- (UIImage*)imageWithImage: (UIImage*) sourceImage
{
    float oldHeight, oldWidth, scaleFactor;
    float newHeight = 0.0;
    float newWidth = 0.0;
    if (scaleSize.height > 0) {
        //scale to fit the height
        oldHeight = sourceImage.size.height;
        scaleFactor = scaleSize.height*[UIScreen mainScreen].scale / oldHeight;
        newWidth = sourceImage.size.width * scaleFactor;
        newHeight = oldHeight * scaleFactor;
    }
    if (scaleSize.width > 0) {
        //scale to fit the width
        oldWidth = sourceImage.size.width;
        scaleFactor = scaleSize.width*[UIScreen mainScreen].scale / oldWidth;
        newHeight = sourceImage.size.height * scaleFactor;
        newWidth = oldWidth * scaleFactor;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
