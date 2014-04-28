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
    UIView *mainTitleView;
    UILabel *title;
    NSString *lastLink;
    BOOL contentShowed;
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
    
    mainTitleView = self.navigationItem.titleView;
    title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50, 0, 100, 44)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    
    linkView = [[UIWebView alloc] init];
    [linkView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (isIOS7?64:44))];
    [linkView setDelegate:self];
    [self.view addSubview:linkView];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.center.x-10, self.view.center.y - 50, 20, 20)];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [linkView addSubview:activity];
    
    loadingTipLB = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 50, activity.frame.origin.y + activity.frame.size.height, 100, 30)];
    loadingTipLB.text = @"正在加载";
    [loadingTipLB setFont:[UIFont systemFontOfSize:12]];
    [loadingTipLB setShadowColor:[UIColor clearColor]];
    [loadingTipLB setBackgroundColor:[UIColor clearColor]];
    [loadingTipLB setTextColor:[UIColor lightGrayColor]];
    [linkView addSubview:loadingTipLB];
    
    UIButton *backBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBtn setFrame:CGRectMake(0, 0, (isIOS7?14:14+IOS6_BAR_BUTTOM_PADDING), 14)];
    [backBarBtn setImage:[UIImage imageNamed:@"navigationbar_backItem.png"] forState:UIControlStateNormal];
    [backBarBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backBarBtn]];
}

- (void)setLink:(NSString *)newlink
{
    lastLink = link;
    link = newlink;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitleView:title];
    if (![lastLink isEqualToString:link]) {
        NSURLRequest *blankrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
        [linkView loadRequest:blankrequest];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:link]];
        [linkView loadRequest:request];
        contentShowed = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setTitleView:mainTitleView];
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
    [self performSelector:@selector(hideLoadingTip) withObject:nil afterDelay:2.0];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading) {
        NSString *lJs = @"document.title";
        NSString *lHtml = [webView stringByEvaluatingJavaScriptFromString:lJs];
        if (lHtml && lHtml.length > 0) {
            title.text = lHtml;
            [title sizeToFit];
        }
    }
    if (![webView.request.URL.absoluteString isEqual:@"about:blank"] && activity.isAnimating) {
        [loadingTipLB setHidden:YES];
        [activity stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        contentShowed = YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!contentShowed) {
        title.text = @"正在加载...";
        [loadingTipLB setHidden:NO];
        [activity startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

@end
