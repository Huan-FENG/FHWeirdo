//
//  FHWebViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-14.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHWebViewController.h"

@interface FHWebViewController ()
{
    UIWebView *linkView;
    UIActivityIndicatorView *activity;
    UILabel *loadingTipLB;
    NSString *lastLink;
}

@end

@implementation FHWebViewController
@synthesize link;

- (id)initWithLink:(NSString *)linkString
{
    self = [super init];
    if (self) {
        link = linkString;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    linkView = [[UIWebView alloc] init];
    [linkView setFrame:self.view.bounds];
    [linkView setDelegate:self];
    [self.view addSubview:linkView];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.center.x-10, self.view.center.y - 100, 20, 20)];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [linkView addSubview:activity];
    
    loadingTipLB = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 50, activity.frame.origin.y + activity.frame.size.height, 100, 30)];
    loadingTipLB.text = @"正在加载";
    [loadingTipLB setFont:[UIFont systemFontOfSize:12]];
    [loadingTipLB setShadowColor:[UIColor clearColor]];
    [loadingTipLB setBackgroundColor:[UIColor clearColor]];
    [loadingTipLB setTextColor:[UIColor lightGrayColor]];
    [linkView addSubview:loadingTipLB];
}

- (void)setLink:(NSString *)newlink
{
    lastLink = link;
    link = newlink;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![lastLink isEqualToString:link]) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:link]];
        [linkView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)hideLoadingTip
{
    [loadingTipLB setHidden:YES];
}

#pragma mark
#pragma mark - webView delegate

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activity stopAnimating];
    [loadingTipLB setHidden:NO];
    loadingTipLB.text = @"加载失败";
    link = nil;
    [loadingTipLB performSelector:@selector(hideLoadingTip) withObject:nil afterDelay:2.0];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loadingTipLB setHidden:YES];
    [activity stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [loadingTipLB setHidden:NO];
    [activity startAnimating];
}

@end
