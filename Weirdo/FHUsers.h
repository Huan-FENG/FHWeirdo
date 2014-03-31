//
//  FHUsers.h
//  Weirdo
//
//  Created by FengHuan on 14-3-20.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHUser.h"

@interface FHUsers : NSObject
{
    NSMutableDictionary *users;
    NSOperationQueue *fetchImageQueue;
}

+ (FHUsers *)sharedUsers;
- (void)addUser:(FHUser *)user;
- (FHUser *)getUserForID:(NSString *)userID;

@end
