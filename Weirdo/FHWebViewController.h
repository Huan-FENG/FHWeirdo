//
//  FHWebViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-4-14.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *link;

- (id)initWithLink:(NSString *)linkString;

@end
