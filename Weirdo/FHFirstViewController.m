//
//  FHFirstViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHFirstViewController.h"
#import "FHHomeNavigationController.h"

@interface FHFirstViewController ()

@end

@implementation FHFirstViewController


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
    if ([[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:nil]) {
        [self presentMainViewController];
    }else
        [self loadLoginWebView];
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
//    FHMainViewController *mainVC = [[FHMainViewController alloc] init];
    [self presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark
#pragma mark - webView delegete

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错拉" message:error.localizedDescription delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:webView.request.URL]) {
        [self presentMainViewController];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
