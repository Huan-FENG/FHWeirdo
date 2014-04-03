//
//  FHImageCache.m
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHImageCache.h"

@implementation FHImageCache

+ (FHImageCache *)sharedImage
{
    static FHImageCache *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self) {
        images = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

- (UIImage *)getImageForURL:(NSString *)URLString
{
    return [images objectForKey:URLString];
}

- (void)cacheImage:(UIImage *)image forURL:(NSString *)URLString
{
    [images setObject:image forKey:URLString];
}

@end
