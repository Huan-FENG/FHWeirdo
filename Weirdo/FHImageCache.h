//
//  FHImageCache.h
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHImageCache : NSObject
{
    NSMutableDictionary *images;
}

+ (FHImageCache *)sharedImage;

- (UIImage *)getImageForURL:(NSString *)URLString;
- (UIImage *)getHighestPxImageForURL:(NSString *)URLString;
- (void)cacheImage:(UIImage *)image forURL:(NSString *)URLString;

@end
