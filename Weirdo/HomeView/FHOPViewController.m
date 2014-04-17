//
//  FHOPViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-8.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHOPViewController.h"
#import "FHImageCache.h"
#import "FHSUStatusBar.h"

@interface FHOPViewController ()
{
    UILabel *title;
    UILabel *charCountLB;
    UIView *statusView;
    UITextView *statusTextView;
    UILabel *statusTextViewPlaceholder;
    StatusOperation operation;
    FHPost *opStatus;
}

@end

@implementation FHOPViewController

@synthesize replyToIDAndName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        float statusbarheight = 0;
        NSString *bgname = @"navigationbar_bg.png";
        if (isIOS7) {
            statusbarheight = 20;
            bgname = @"navigationbar_bg-568h.png";
        }
        
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44 + statusbarheight)];
        [barView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:bgname]]];
        [self.view addSubview:barView];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(barView.center.x-50, statusbarheight, 100, 35)];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:16.0]];
        [title setShadowColor:[UIColor lightGrayColor]];
        [title setShadowOffset:CGSizeMake(0.5, 0.5)];
        [title setBackgroundColor: [UIColor clearColor]];
        [barView addSubview:title];
        
        charCountLB = [[UILabel alloc] initWithFrame:CGRectMake(title.frame.origin.x, title.frame.origin.y+title.frame.size.height-5, title.frame.size.width, 10)];
        [charCountLB setTextColor:[UIColor whiteColor]];
        [charCountLB setBackgroundColor:[UIColor clearColor]];
        [charCountLB setFont:[UIFont systemFontOfSize:10.0]];
        [charCountLB setShadowColor:[UIColor clearColor]];
        [barView addSubview:charCountLB];
        
        UIButton *closeBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBT setTitle:@"取消" forState:UIControlStateNormal];
        [closeBT.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [closeBT setFrame:CGRectMake(10, 10+statusbarheight, 30, 30)];
        [closeBT setContentMode:UIViewContentModeCenter];
        [closeBT addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:closeBT];
        
        UIButton *doneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBT setFrame:CGRectMake(280, closeBT.frame.origin.y, closeBT.frame.size.width, closeBT.frame.size.height)];
        UIImageView *doneBT_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationbar_sendItem.png"]];
        doneBT_bg.center = CGPointMake(doneBT.frame.size.width/2, doneBT.frame.size.height/2);
        [doneBT addSubview:doneBT_bg];
        [doneBT addTarget:self action:@selector(didFinishEditing) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:doneBT];
        
        statusView = [[UIView alloc] initWithFrame:CGRectMake(0, barView.frame.size.height, 320, 70)];
        [statusView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
        [self.view addSubview:statusView];
        
        statusTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, statusView.frame.size.height+statusView.frame.origin.y, 320, self.view.frame.size.height-statusView.frame.size.height)];
        [statusTextView setFont:[UIFont fontWithName:@"Heiti SC" size:15]];
        [statusTextView setDelegate:self];
        [statusTextView setShowsVerticalScrollIndicator:YES];
        [statusTextView setScrollEnabled:YES];
        [self.view addSubview:statusTextView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordShowed:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDismissed) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setupWithPost:(FHPost *)post operation:(StatusOperation)statusOperation
{
    operation = statusOperation;
    opStatus = post;
    
    UIImageView *postThumb = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
    [postThumb setContentMode:UIViewContentModeScaleAspectFit];
    NSString *thumbURLString;
    if (post.picURLs && post.picURLs.count > 0) {
        thumbURLString = [post.picURLs objectAtIndex:0];
    }else if (post.retweeted.picURLs && post.retweeted.picURLs.count>0)
        thumbURLString = [post.retweeted.picURLs objectAtIndex:0];
    if (thumbURLString) {
        postThumb.image = [[FHImageCache sharedImage] getImageForURL:thumbURLString];
    }
    if (!postThumb.image) {
        postThumb.image = [UIImage imageNamed:@"default_status_thumb.png"];
    }
    
    UILabel *usernameLB = [[UILabel alloc] initWithFrame:CGRectMake(postThumb.frame.size.width+postThumb.frame.origin.x + 10, 5, statusView.frame.size.width-10*2-postThumb.frame.size.width - 5, 15)];
    [usernameLB setBackgroundColor:[UIColor clearColor]];
    [usernameLB setFont:[UIFont systemFontOfSize:12.0]];
    [usernameLB setTextAlignment:NSTextAlignmentLeft];
    usernameLB.text = [NSString stringWithFormat:@"@%@", post.retweeted.username? :post.username];
        
    UILabel *contentLB = [[UILabel alloc] initWithFrame:CGRectMake(usernameLB.frame.origin.x, usernameLB.frame.origin.y+usernameLB.frame.size.height, usernameLB.frame.size.width, statusView.frame.size.height - usernameLB.frame.size.height - usernameLB.frame.origin.y*2)];
    [contentLB setTextAlignment:NSTextAlignmentLeft];
    [contentLB setBackgroundColor:[UIColor clearColor]];
    [contentLB setFont:[UIFont systemFontOfSize:11.0]];
    [contentLB setTextColor:[UIColor lightGrayColor]];
    [contentLB setShadowColor:[UIColor clearColor]];
    [contentLB setNumberOfLines:4];
    [contentLB setLineBreakMode:NSLineBreakByTruncatingTail];
    contentLB.text = post.retweeted.text? :post.text;
        
    [statusView addSubview:postThumb];
    [statusView addSubview:usernameLB];
    [statusView addSubview:contentLB];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *text;
    if (operation == StatusOperationRetweet) {
        text = [NSString stringWithFormat:@"//@%@:%@", opStatus.username, opStatus.text];
        statusTextView.text = [NSString stringWithFormat:@"//@%@:%@", opStatus.username, opStatus.text];
    }else
        [self showTextViewPlaceholder];
    
    switch (operation) {
        case StatusOperationReply:
            title.text = @"回复评论";
            break;
        case StatusOperationRetweet:
            title.text = @"转发微博";
            break;
        case StatusOperationComment:
            title.text = @"撰写评论";
            break;
        default:
            break;
    }
    [statusTextView becomeFirstResponder];
    statusTextView.selectedRange = NSMakeRange(0, 0);
    charCountLB.text = [NSString stringWithFormat:@"%d/140字", statusTextView.text.length];
}

- (void)didReceiveMemoryWarning
{
    DLog();
    [super didReceiveMemoryWarning];
}

- (void)didFinishEditing
{
    
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc] init];
    [property setAfterFailedSelector:@selector(sendFailed:)];
    [property setAfterFailedTarget:self];
    [property setAfterFinishedSelector:@selector(sendSuccess:)];
    [property setAfterFinishedTarget:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
    FHSUStatusBar *statusbar = [[FHSUStatusBar alloc] init];
    NSString *message;
    switch (operation) {
        case StatusOperationComment:
            [[FHWeiBoAPI sharedWeiBoAPI] commentStatus:opStatus.ID content:statusTextView.text commentTo:0 interactionProperty:property];
            message = @"评论发送中...";
            break;
        case StatusOperationReply:
            [[FHWeiBoAPI sharedWeiBoAPI] replyComment:[replyToIDAndName.allKeys objectAtIndex:0] Status:opStatus.ID content:statusTextView.text commentTo:1 interactionProperty:property];
            message = @"回复发送中...";
            break;
        case StatusOperationRetweet:
            [[FHWeiBoAPI sharedWeiBoAPI] retweetStatus:opStatus.ID content:statusTextView.text commentTo:0 interactionProperty:property];
            message = @"微博转发中...";
            break;
        default:
            break;
    }
    [statusbar showStatusMessage:message];
}

- (void)sendFailed:(NSError *)error
{
    NSString *message;
    switch (operation) {
        case StatusOperationComment:
            message = @"评论发送失败";
            break;
        case StatusOperationReply:
            message = @"回复发送失败";
            break;
        case StatusOperationRetweet:
            message = @"转发微博失败";
            break;
        default:
            break;
    }
    FHSUStatusBar *statusbar = [[FHSUStatusBar alloc] init];
    [statusbar showStatusMessage:message];
}

- (void)sendSuccess:(NSDictionary *)successResponse
{
    if (successResponse) {
        NSString *message;
        switch (operation) {
            case StatusOperationComment:
                message = @"评论发送成功";
                break;
            case StatusOperationReply:
                message = @"回复发送成功";
                break;
            case StatusOperationRetweet:
                message = @"转发微博成功";
                break;
            default:
                break;
        }
        FHSUStatusBar *statusbar = [[FHSUStatusBar alloc] init];
        [statusbar showStatusMessage:message];
    }else
        [self sendFailed:nil];
}

- (void)showTextViewPlaceholder
{
    if (!statusTextViewPlaceholder) {
        statusTextViewPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 15)];
        [statusTextViewPlaceholder setFont:statusTextView.font];
        [statusTextViewPlaceholder setBackgroundColor:[UIColor clearColor]];
        [statusTextView addSubview:statusTextViewPlaceholder];
        [statusTextViewPlaceholder setTextColor:[UIColor lightGrayColor]];
        [statusTextViewPlaceholder setEnabled:NO];
        [statusTextViewPlaceholder setTextAlignment:NSTextAlignmentLeft];
        [statusTextViewPlaceholder setShadowColor:[UIColor clearColor]];
    }
    [statusTextViewPlaceholder setHidden:NO];

    switch (operation) {
        case StatusOperationRetweet:
            statusTextViewPlaceholder.text = @"说点儿什么呢";
            break;
        case StatusOperationComment:
            statusTextViewPlaceholder.text = @"待我评论一番";
            break;
        case StatusOperationReply:
            statusTextViewPlaceholder.text = [NSString stringWithFormat:@"回复@%@:", [[replyToIDAndName allValues] objectAtIndex:0]];
            break;
        default:
            break;
    }
}

- (void)hideTextViewPlaceholder
{
    statusTextViewPlaceholder.hidden?:[statusTextViewPlaceholder setHidden:YES];
}

#pragma mark
#pragma mark - textView delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [self showTextViewPlaceholder];
    }else
        [self hideTextViewPlaceholder];
    
    int length = 0;
    UITextRange *range = [textView markedTextRange];
    NSString *markedText = [textView textInRange:range];
    if (markedText) {
        length = textView.text.length - markedText.length;
    }else
        length = textView.text.length;
    
    if (length>140) {
        NSRange selectedRange = textView.selectedRange;
        textView.text = [textView.text substringToIndex:140];
        [charCountLB setTextColor:[UIColor colorWithRed:256.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1.0]];
        length = 140;
        textView.selectedRange = selectedRange;
    }else
        [charCountLB setTextColor:[UIColor whiteColor]];
    charCountLB.text = [NSString stringWithFormat:@"%d/140字", length];
}

#pragma mark
#pragma mark - NSNotification

- (void)keybordShowed:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = statusTextView.contentInset;
    contentInsets = UIEdgeInsetsMake(contentInsets.top, contentInsets.left, kbSize.height + 30, contentInsets.right);
    statusTextView.contentInset = contentInsets;
    statusTextView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDismissed
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    statusTextView.contentInset = contentInsets;
    statusTextView.scrollIndicatorInsets = contentInsets;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
