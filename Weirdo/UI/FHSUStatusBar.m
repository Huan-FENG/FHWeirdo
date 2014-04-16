//
//  FHSUStatusBar.m
//  CRPharmaceultics
//
//  Created by FengHuan on 13-5-28.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "FHSUStatusBar.h"

@implementation FHSUStatusBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGRect frame = [UIApplication sharedApplication].statusBarFrame;
        frame.origin.x = frame.origin.x;
        frame.size.width = frame.size.width;
        self.frame = frame;
        
        self.backgroundColor = [UIColor blackColor];
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [contentView setBackgroundColor:[UIColor blackColor]];
        
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 15, 15)];
        logo.image = [UIImage imageNamed:@"logoStatus.png"];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(self.frame)-50, CGRectGetHeight(self.frame))];
        [messageLabel setShadowColor:[UIColor clearColor]];
        [messageLabel setBackgroundColor:[UIColor blackColor]];
        [messageLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [contentView addSubview:messageLabel];
        [contentView addSubview:logo];
        [self addSubview:contentView];
    }
    
    return self;
}

- (void)showStatusMessage:(NSString *)message
{
    self.hidden = NO;
    self.alpha = 0.0f;
    float boundsWidth = self.bounds.size.width;
    
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:12]];
    if (size.width < messageLabel.bounds.size.width) {
        CGRect logoRect = logo.frame;
        logoRect.origin.x = (boundsWidth - 20 - size.width)/2;
        [logo setFrame:logoRect];
        CGRect messageRect = messageLabel.frame;
        messageRect.origin.x = logo.frame.origin.x + logo.bounds.size.width + 5;
        messageRect.size.width = size.width;
        [messageLabel setFrame:messageRect];
    }
    messageLabel.text = message;
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished){
        messageLabel.text = message;
        [self performSelector:@selector(hide) withObject:self afterDelay:3.0];
    }];
}

- (void)hide
{
    self.alpha = 1.0f;
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        messageLabel.text = @"";
        self.hidden = YES;
    }];;
}

@end
