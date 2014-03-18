//
//  FHFirstViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHFirstViewController.h"
#import "FHMainViewController.h"

@interface FHFirstViewController ()

@end

@implementation FHFirstViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:nil]) {
        [self presentMainViewController];
    }else
        [self loadLoginWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLoginWebView
{
    loginWebView = [[UIWebView alloc] init];
    [loginWebView setFrame:self.view.frame];
    [self.view addSubview:loginWebView];
    NSURL *authorizeURL = [[FHWeiBoAPI sharedWeiBoAPI] authorizeURL];
    NSURLRequest *loginRequest = [[NSURLRequest alloc] initWithURL:authorizeURL];
    [loginWebView setDelegate:self];
    [loginWebView loadRequest:loginRequest];
}

- (void)presentMainViewController
{
    FHMainViewController *mainVC = [[FHMainViewController alloc] init];
    [self presentViewController:mainVC animated:YES completion:nil];
}

#pragma mark
#pragma mark - webView delegete

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[FHWeiBoAPI sharedWeiBoAPI] isAuthorized:webView.request.URL]) {
        [self presentMainViewController];
    }
}
@end
