//
//  FHPost.h
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FHPost : NSObject

@property (nonatomic) BOOL favorited;
@property (nonatomic) NSString *createdTime;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *source;
@property (nonatomic) NSArray *picURLs;
@property (nonatomic) FHPost *retweeted;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *username;
//@property (nonatomic) UIImage *userImage;
@property (nonatomic) NSString *reporstsCount;
@property (nonatomic) NSString *commentsCount;
@property (nonatomic) NSString *voteCounts;

- (id)initWithPostDic:(NSDictionary *)original;

@end
