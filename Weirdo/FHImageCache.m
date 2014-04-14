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
        images = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (UIImage *)getImageForURL:(NSString *)URLString
{
    return [images objectForKey:URLString];
}

- (UIImage *)getHighestPxImageForURL:(NSString *)URLString
{
    NSString *highestPxImageURL = [URLString stringByReplacingOccurrencesOfString:@"/thumbnail/" withString:@"/large/"];
    return [self getImageForURL:highestPxImageURL];
}

- (void)cacheImage:(UIImage *)image forURL:(NSString *)URLString
{
    [images setObject:image forKey:URLString];
    if (images.count > 20) {
        [images removeObjectsForKeys:[[images allKeys] subarrayWithRange:NSMakeRange(0, 5)]];
    }
}

@end
