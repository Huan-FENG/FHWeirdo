//
//  FHContentImageView.m
//  Weirdo
//
//  Created by FengHuan on 14-4-1.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHContentImageView.h"

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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
        [imageView setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imageView];
        [self loadImage:[imageURLs objectAtIndex:0] forImageView:imageView];
    }else{
        [self setFrame:CGRectMake(0, 0, PADDING + (PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT) * 3, height)];
        for (int i = 0; i<imageURLs.count; i++) {
            int row = i/3;
            int column = i%3;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING + (PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT)*column, ( PADDING + CONTENT_MULTI_IMAGE_VIEW_HIGHT)*row, CONTENT_MULTI_IMAGE_VIEW_HIGHT, CONTENT_MULTI_IMAGE_VIEW_HIGHT)];
            [imageView setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:imageView];
            [self loadImage:[imageURLs objectAtIndex:i] forImageView:imageView];
        }
    }
}

- (void)loadImage:(NSString *)URLString forImageView:(UIImageView *)imageView
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [NSURLConnection sendAsynchronousRequest:request queue:downloadImageQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (imageView) {
            UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
            image = [FHContentImageView imageWithImage:image];
            [imageView setClipsToBounds:YES];
            [imageView setAlpha:0.0];
            [imageView setImage:image];
            [imageView setBackgroundColor:[UIColor clearColor]];
            [UIView animateWithDuration:0.5 animations:^(void){
                [imageView setAlpha:1.0];
            }];
        }
    }];
}

+ (float)getViewHeightForImageCount:(int)count
{
    float height;
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

+(UIImage*)imageWithImage: (UIImage*) sourceImage
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = CONTENT_SINGLE_IMAGE_HIGHT*2 / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
