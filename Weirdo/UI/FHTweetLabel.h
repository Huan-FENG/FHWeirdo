//
//  FHTweetLabel.h
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHTweetLabel : UILabel
{
    UIColor *colorHashtag;
    UIColor *colorLink;
    NSMutableDictionary *colorRanges;
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constarintToWidth:(float)width;

@end
