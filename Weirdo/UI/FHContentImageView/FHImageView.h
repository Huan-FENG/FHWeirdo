//
//  FHImageView.h
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHImageView : UIImageView

@property (nonatomic, assign) BOOL needScale;
@property (nonatomic, assign) CGSize scaleSize;

- (void)loadImageForURL:(NSString *)URLString;
@end
