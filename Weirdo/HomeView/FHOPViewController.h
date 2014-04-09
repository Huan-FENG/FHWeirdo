//
//  FHOPViewController.h
//  Weirdo
//
//  Created by FengHuan on 14-4-8.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    StatusOperationReply,
    StatusOperationRetweet,
    StatusOperationComment,
} StatusOperation;

@interface FHOPViewController : UIViewController <UITextViewDelegate>

- (void)setupWithPost:(FHPost *)post operation:(StatusOperation)statusOperation;

@end
