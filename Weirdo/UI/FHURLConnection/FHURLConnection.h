//
//  FHURLConnection.h
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-2-28.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHURLConnection : NSURLConnection
{
    NSMutableData *receivedData;
}

@property (nonatomic, strong) id connectionDelegate;

@end
