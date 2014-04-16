//
//  FHURLConnection.m
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-2-28.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#define CONNECTIONID @"connectionID"

#import "FHURLConnection.h"
#import "FHConnectionParse.h"

@implementation FHURLConnection

@synthesize connectionDelegate;

- (id)init
{
    if ((self = [super init]) != nil)
    {
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    if ((self = [super init]) != nil)
    {
        self = [super initWithRequest:request delegate:self startImmediately:NO];
        NSString *connectionID = [NSString stringWithFormat: @"%ld", ((intptr_t) self)];
        [FHConnectionParse parseRequest:request forConnectionID:connectionID];
        self.connectionDelegate = delegate;
        [self start];
    }
    return self;
}

- (void)start
{
    [super start];
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error
{
    int value = arc4random();
    NSString *connectionID = [NSString stringWithFormat:@"%d", value];
    [FHConnectionParse parseRequest:request forConnectionID:connectionID];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error ];
    [FHConnectionParse parseResponseData:[data copy] forConnectionID:connectionID];
    return data;
}

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [[self alloc] initWithRequest:request delegate:delegate];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *connectionID = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
    [FHConnectionParse parseResponseData:[receivedData copy] forConnectionID:connectionID];
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [connectionDelegate connectionDidFinishLoading:connection];
    }
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [receivedData setLength:0];
    
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [connectionDelegate connection:connection didFailWithError:error];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (!receivedData) {
        receivedData = [[NSMutableData alloc] init];
    }
    [receivedData setLength:0];
    
//    NSString *connectionID = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
//    [FHConnectionParse parseResponse:response forConnectionID:connectionID];
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [connectionDelegate connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [connectionDelegate connection:connection didReceiveData:data];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [connectionDelegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
    }
    return request;
}
@end
