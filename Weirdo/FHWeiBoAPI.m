//
//  FHWeiBoAPI.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "FHWeiBoAPI.h"

@implementation FHWeiBoAPI

static NSString *APIServer = @"https://api.weibo.com";
static NSString *APIRedirectURI = @"https://api.weibo.com/oauth2/default.html";

+ (FHWeiBoAPI *)sharedWeiBoAPI
{
    static FHWeiBoAPI *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    if (!appKey) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        appKey = [defaults objectForKey:@"appKey"]?:@"897481256";
        appSecretKey = [defaults objectForKey:@"appSecretKey"]?:@"83a6102c1435001a6d52cdd254cc7cbc";
        token = [defaults objectForKey:@"token"];
        uid = [defaults objectForKey:@"uid"];
        [self synchronize];
    }
    if (!connections) {
        connections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)synchronize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (appKey) {
        [defaults setObject:appKey forKey:@"appKey"];
    }
    if (appSecretKey) {
        [defaults setObject:appSecretKey forKey:@"appSecretKey"];
    }
    if (token) {
        [defaults setObject:token forKey:@"token"];
    }
    if (uid) {
        [defaults setObject:uid forKey:@"uid"];
    }
}

- (NSDictionary *)postURL:(NSString *)URLString withConnectionInteractionProperty:(FHConnectionInterationProperty *)properties error:(NSError **)erro
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    if (properties) {
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
        [connections setObject:properties forKey:connectionKey];
    }else{
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:erro];
        if (!*erro && response) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            *erro = [self isRespondError:dic];
            if (!*erro)
                return dic;
        }
    }
    return nil;
}

- (NSDictionary *)getURL:(NSString *)URLString withConnectionInteractionProperty:(FHConnectionInterationProperty *)properties error:(NSError **)erro
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"GET"];
    if (properties) {
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
        [connections setObject:properties forKey:connectionKey];
    }else{
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:erro];
        if (!*erro && response) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            *erro = [self isRespondError:dic];
            if (!*erro)
                return dic;
        }
    }
    return nil;
}

- (NSError *)isRespondError:(NSDictionary *)response
{
    NSError *erro;
    if ([response objectForKey:@"error_code"]) {
        int errorCode = [[response objectForKey:@"error_code"] integerValue];
        switch (errorCode) {
            case 21314:
            case 21315:
            case 21316:
            case 21317:
            // token invalid
                break;
                
            default:
                break;
        }
        erro = [NSError errorWithDomain:@"WeiBoErrorDomain" code:errorCode userInfo:[response objectForKey:@"error"]];
    }
    return erro;
}

- (NSURL *)authorizeURL
{
    NSString *paramString = [NSString stringWithFormat:@"client_id=%@&redirect_uri=%@&display=mobile", appKey, APIRedirectURI];
    NSString *URLString = [NSString stringWithFormat:@"%@/oauth2/authorize?%@", APIServer, paramString];
    return [NSURL URLWithString:URLString];
}

- (BOOL)checkToken
{
    NSString *paramString = [NSString stringWithFormat:@"access_token=%@", token];
    NSString *URLString = [NSString stringWithFormat:@"%@/2/account/get_uid.json?%@", APIServer, paramString];
    NSError *error;
    [self getURL:URLString withConnectionInteractionProperty:nil error:&error];
    if (error) {
        return NO;;
    }
    return YES;
}

- (void)getAccountTokenWithCode:(NSString *)code
{
    NSString *paramString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&code=%@&redirect_uri=%@", appKey, appSecretKey, code, APIRedirectURI];
    NSString *URLString = [NSString stringWithFormat:@"%@/oauth2/access_token?%@", APIServer, paramString];
    NSError *error;
    NSDictionary *response = [self postURL:URLString withConnectionInteractionProperty:nil error:&error];
    if (response) {
        token = [response objectForKey:@"access_token"];
        uid = [response objectForKey:@"uid"];
        [self synchronize];
    }
}

- (BOOL)isAuthorized:(NSURL *)redirectURL
{
    if (!redirectURL) {
        return [self checkToken];
    }else{
        NSString *authorizeString = redirectURL.absoluteString;
        NSRange codeRange = [authorizeString rangeOfString:@"code="];
        if (codeRange.location != NSNotFound) {
            NSString *code = [authorizeString substringFromIndex:(codeRange.location+codeRange.length)];
            DLog(@"code: %@",code);
            [self getAccountTokenWithCode:code];
            return YES;
        }
    }
    return NO;
}

#pragma mark
#pragma mark - connecetion delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
	FHConnectionInterationProperty * properties = [connections objectForKey:connectionKey];
	NSMutableData *data = [[NSMutableData alloc] init];
    [properties setData:data];
    
    if (properties.progressTarget) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)])
        {
            NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
            NSNumber *contentLength = [NSNumber numberWithLongLong:[[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue]];
            [properties setContentLength:contentLength];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
	FHConnectionInterationProperty *properties = [connections objectForKey:connectionKey];
	NSMutableData * oldData = (NSMutableData *) properties.data;
	[oldData appendData:data];
    
    if (properties.progressTarget && properties.progressSelector)
    {
        SEL action = NSSelectorFromString(properties.progressSelector);
        SuppressPerformSelectorLeakWarning([properties.progressTarget performSelector:action withObject:[properties progressRate]]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
	FHConnectionInterationProperty *properties = [connections objectForKey:connectionKey];
	// perform necessary callbacks with the data.
    
	if (properties.afterFailedSelector && properties.afterFailedTarget)
	{
		SEL action = NSSelectorFromString(properties.afterFailedSelector);
        SuppressPerformSelectorLeakWarning([properties.afterFailedTarget performSelector:action withObject:error]);
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *connectionKey = [NSString stringWithFormat: @"%ld", ((intptr_t) connection)];
	FHConnectionInterationProperty *properties = [connections objectForKey:connectionKey];
    
	// perform necessary callbacks with the data.
	if (properties.afterFinishedTarget && properties.afterFinishedSelector)
	{
		SEL action = NSSelectorFromString(properties.afterFinishedSelector);
        SuppressPerformSelectorLeakWarning([properties.afterFinishedTarget performSelector:action withObject:properties.data]);
	}
	[connections removeObjectForKey:connectionKey];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

@end
