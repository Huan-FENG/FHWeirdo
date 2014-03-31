//
//  FHConnectionInterationProperty.h
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHConnectionInterationProperty : NSObject

@property (nonatomic, strong) id afterFailedTarget;
@property (nonatomic) SEL afterFailedSelector;
@property (nonatomic, strong) id afterFinishedTarget;
@property (nonatomic) SEL afterFinishedSelector;
@property (nonatomic, strong) id progressTarget;
@property (nonatomic) SEL progressSelector;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSNumber *contentLength;

- (NSNumber *)progressRate;
@end
