//
//  FHUser.h
//  Weirdo
//
//  Created by FengHuan on 14-3-20.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHUser : NSObject

@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *profileImageURL;
@property (nonatomic) NSString *followersCount;
@property (nonatomic) NSString *friendsCount;
@property (nonatomic) NSString *postsCount;

- (id)initWithOriginalData:(NSDictionary *)original;
@end
