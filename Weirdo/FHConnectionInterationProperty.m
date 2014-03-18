//
//  FHConnectionInterationProperty.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHConnectionInterationProperty.h"

@implementation FHConnectionInterationProperty

@synthesize afterFailedSelector, afterFailedTarget, afterFinishedSelector, afterFinishedTarget, progressSelector, progressTarget, data, contentLength;

- (NSNumber *)progressRate
{
    float progressRate = (data.length/[contentLength floatValue]);
    return  [NSNumber numberWithFloat:progressRate];
}
@end
