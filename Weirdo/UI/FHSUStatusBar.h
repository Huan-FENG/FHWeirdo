//
//  FHSUStatusBar.h
//  CRPharmaceultics
//
//  Created by FengHuan on 13-5-28.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHSUStatusBar : UIWindow{
    UILabel *messageLabel;
    UIImageView *logo;
}

- (void)showStatusMessage:(NSString *)message;

@end
