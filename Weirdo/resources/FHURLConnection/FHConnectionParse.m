//
//  FHConnectionParse.m
//  FHURLConnectionTest
//
//  Created by FengHuan on 14-3-3.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#define PARSE_KEY_URLBASE @"urlbase"
#define PARSE_KEY_URLPARMETERS @"urlparms"
#define PARSE_KEY_URLBODYPARMETERS @"urlBodyParms"
#define PARSE_KEY_TIME @"time"
#define PARSE_KEY_CONNECTIONTYPE @"connectionType"
#define PARSE_KEY_CONNECTIONID @"connectionID"
//#define PARSE_KEY_RESPONSECODE @"responseCode"
#define PARSE_KEY_RESPONSEPDATA @"responseData"

#import "FHConnectionParse.h"
#import "FHConnectionLog.h"
#import "Reachability/Reachability.h"

@interface FHConnectionParse (Private)

- (NSMutableDictionary *)parseURLToDic:(NSURL *)url;
- (NSDictionary *)parseBodyToDic:(NSData *)bodyData;
- (NSMutableDictionary *)parseStringParmsToDic:(NSString *)stringParms;
- (NSString *)parseDataToString:(NSData *)data;
- (void)parseRequest:(NSURLRequest *)request forConnectionID:(NSString *)connectionId;

@end

@implementation FHConnectionParse

- (NSDictionary *)parseURLToDic:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    NSMutableDictionary *urlDic = [[NSMutableDictionary alloc] init];
    NSUInteger location = [urlString rangeOfString:@"?"].location;
    NSString *urlbase;
    if (location != NSNotFound) {
        urlbase = [urlString substringToIndex:location];
    }else{
        [urlDic setObject:urlString forKey:PARSE_KEY_URLBASE];
        return urlDic;
    }
    
    NSString *urlParms = [urlString substringFromIndex:location+1];
    NSMutableDictionary *parmsDic = [self parseStringParmsToDic:urlParms];
    [urlDic setObject:urlbase forKey:PARSE_KEY_URLBASE];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parmsDic options:0 error:nil];
    NSString *parmsDicString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [urlDic setObject:parmsDicString forKey:PARSE_KEY_URLPARMETERS];
    return urlDic;
}

- (NSDictionary *)parseBodyToDic:(NSData *)bodyData
{
    NSString *bodyString = [self parseDataToString:bodyData];
    NSDictionary *bodyParmsDic = [self parseStringParmsToDic:bodyString];
    NSDictionary *bodyDic;
    if (bodyParmsDic.count != 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParmsDic options:0 error:nil];
        NSString *bodyParmsDicString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        bodyDic = [NSDictionary dictionaryWithObject:bodyParmsDicString forKey:PARSE_KEY_URLBODYPARMETERS];
    }
    return bodyDic;
}

- (NSString *)parseDataToString:(NSData *)data
{
    NSString *responseString, *responseStringASCII, *responseStringUTF8;
    
    responseStringASCII = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if (!responseStringASCII)
        // ASCII is not working, will try utf-8!
        responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    else
    {
        //  ASCII is working, but check if UTF8 gives less characters
        responseStringUTF8  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(responseStringUTF8 != nil && [responseStringUTF8 length] < [responseStringASCII length])
            responseString  =   responseStringUTF8;
        else
            responseString  =   responseStringASCII;
    }
    return responseString;
}

- (NSDictionary *)parseStringParmsToDic:(NSString *)stringParms
{
    NSArray *parms = [stringParms componentsSeparatedByString:@"&"];
    NSMutableDictionary *parmsDic = [[NSMutableDictionary alloc] init];
    for (NSString *parm in parms) {
        NSArray *keyvalue = [parm componentsSeparatedByString:@"="];
        if (keyvalue.count == 2) {
            [parmsDic setObject:[keyvalue objectAtIndex:1] forKey:[keyvalue objectAtIndex:0]];
        }else
            DLog(@"cann't parse stringParm: %@", parm);
    }
    return parmsDic;
}

- (void)parseRequest:(NSURLRequest *)request forConnectionID:(NSString *)connectionId
{
    NSMutableDictionary *connectionDic = [[NSMutableDictionary alloc] init];
    [connectionDic addEntriesFromDictionary: [self parseURLToDic:request.URL]];
    [connectionDic addEntriesFromDictionary:[self parseBodyToDic:request.HTTPBody]];
    [connectionDic setObject: [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] forKey:PARSE_KEY_TIME];
    [connectionDic setObject:request.HTTPMethod forKey:PARSE_KEY_CONNECTIONTYPE];
    [connectionDic setObject:connectionId forKey:PARSE_KEY_CONNECTIONID];
    [[FHConnectionLog sharedLog] cacheConnectionLog:[FHConnectionParse parseConnectionLog:connectionDic]];
}

- (void)parseResponseData:(NSData *)data forConnectionID:(NSString *)connectionId
{
    NSMutableDictionary *connectionDic = [[NSMutableDictionary alloc] init];
    [connectionDic setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] forKey:PARSE_KEY_TIME];
    [connectionDic setObject:@"data" forKey:PARSE_KEY_CONNECTIONTYPE];
    
    id jsonToObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (jsonToObject) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [connectionDic setObject:jsonString forKey:PARSE_KEY_RESPONSEPDATA];
//        [connectionDic setObject:jsonToObject forKey:PARSE_KEY_RESPONSEPDATA];
    }
    [connectionDic setObject:connectionId forKey:PARSE_KEY_CONNECTIONID];
    [[FHConnectionLog sharedLog] cacheConnectionLog:[FHConnectionParse parseConnectionLog:connectionDic]];
}

+ (NSString *)parseConnectionLog:(NSDictionary *)connectionLog
{
//  ID || type || time || urlbase || urlparms || urlbodyparms || responsedata
    NSString *stringLog;
    if (!connectionLog) {
        // init the first line of the Log file
        stringLog = @"ID\ttype\ttime\turlbase\turlparms\turlbodyparms\tresponsedata\tstatus\n";
    }else{
        NSDictionary *data = [connectionLog objectForKey:PARSE_KEY_RESPONSEPDATA];
        NSString *theData;
        if (data) {
            theData = [data description];
        }
        stringLog = [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%d\n", [connectionLog objectForKey:PARSE_KEY_CONNECTIONID], [connectionLog objectForKey:PARSE_KEY_CONNECTIONTYPE], [connectionLog objectForKey:PARSE_KEY_TIME], [connectionLog objectForKey:PARSE_KEY_URLBASE], [connectionLog objectForKey:PARSE_KEY_URLPARMETERS], [connectionLog objectForKey:PARSE_KEY_URLBODYPARMETERS], theData, [Reachability reachabilityForInternetConnection].currentReachabilityStatus];
    }
    return stringLog;
}

//- (void)parseResponse:(NSURLResponse *)response forConnectionID:(NSString *)connectionId
//{
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    NSMutableDictionary *connectionDic = [[NSMutableDictionary alloc] init];
//    [connectionDic setObject:[NSDate date] forKey:PARSE_KEY_TIME];
//    [connectionDic setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:PARSE_KEY_RESPONSECODE];
//    [connectionDic setObject:@"response" forKey:PARSE_KEY_CONNECTIONTYPE];
//    NSMutableDictionary *connectionLog = [[NSMutableDictionary alloc] init];
//    [connectionLog setObject:connectionDic forKey:connectionId];
//    [[FHConnectionLog sharedLog] cacheConnectionLog:connectionLog];
////    DLog(@"connection %@", connection);
//}

+ (void)parseRequest:(NSURLRequest *)request forConnectionID:(NSString *)connectionId
{
    [[self alloc] parseRequest:request forConnectionID:connectionId];
}

+ (void)parseResponse:(NSURLResponse *)response forConnectionID:(NSString *)connectionId
{
    [[self alloc] parseResponse:response forConnectionID:connectionId];
}

+ (void)parseResponseData:(NSData *)data forConnectionID:(NSString *)connectionId
{
    [[self alloc] parseResponseData:data forConnectionID:connectionId];
}
@end
