//
//  FHFirstViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHFirstViewController.h"
#import "FHHomeNavigationController.h"

#define CHECK_VERSION_TAG 00101

@interface FHFirstViewController ()
{
    NSString *update_url;
}
@end

@implementation FHFirstViewController

@synthesize reLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (isPhone5) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"default-568h.png"]]];
    }else
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"default.png"]]];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activity setFrame:CGRectMake(self.view.center.x-10, self.view.frame.size.height - 40, 20, 20)];
    [activity startAnimating];
    [self.view addSubview:activity];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (reLogin) {
        [self loadLoginWebView];
        return;
    }
    
    NSError *error = [[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:nil];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"出错啦" message:error.localizedDescription delegate:self cancelButtonTitle:@"重新授权" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        NSDictionary *checkresult = [[FHWeiBoAPI sharedWeiBoAPI] checkVersion];
        if (checkresult) {
            NSString *message = [[[checkresult objectForKey:@"changelog"] componentsSeparatedByString:@"|"] objectAtIndex:0];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新版本可用" message:message delegate:self cancelButtonTitle:@"稍后更新" otherButtonTitles:@"前往更新", nil];
            update_url = [checkresult objectForKey:@"update_url"];
            alert.tag = CHECK_VERSION_TAG;
            [alert show];
        }else{
            [self presentMainViewController];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLoginWebView
{
    if (!loginWebView) {
        loginWebView = [[UIWebView alloc] init];
        [loginWebView setFrame:self.view.frame];
        [self.view addSubview:loginWebView];
    }
    NSURL *authorizeURL = [[FHWeiBoAPI sharedWeiBoAPI] authorizeURL];
    NSURLRequest *loginRequest = [[NSURLRequest alloc] initWithURL:authorizeURL];
    [loginWebView setDelegate:self];
    [loginWebView loadRequest:loginRequest];
}

- (void)presentMainViewController
{
    FHHomeNavigationController *mainVC = [[FHHomeNavigationController alloc] init];
    [mainVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark
#pragma mark - webView delegete

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错拉" message:error.localizedDescription delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSError *error = [[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:webView.request.URL];
    if (error.code == ERROR_AUTHORIZE_DID_NOT_COMPLETED)
        return;
    
    if (!error) {
        [self presentMainViewController];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"出错啦" message:error.localizedDescription delegate:self cancelButtonTitle:@"重新授权" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHECK_VERSION_TAG) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (update_url) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:update_url]];
            }
        }
        [self presentMainViewController];
    }else{
        [self loadLoginWebView];
    }
}

@end
