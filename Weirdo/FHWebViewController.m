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
}

@end

@implementation FHWebViewController
@synthesize link;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [loadingTipLB setBackgroundColor:[UIColor clearColor]];
    [loadingTipLB setTextColor:[UIColor grayColor]];
    [linkView addSubview:loadingTipLB];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![linkView.request.URL.absoluteString isEqualToString:link]) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:link]];
        [linkView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    loadingTipLB.text = @"加载失败！";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
