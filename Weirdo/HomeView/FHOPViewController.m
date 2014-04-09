//
//  FHOPViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-8.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHOPViewController.h"
#import "FHImageCache.h"

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [barView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_bg.png"]]];
        [self.view addSubview:barView];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(barView.center.x-50, 0, 100, 35)];
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
        [closeBT setFrame:CGRectMake(10, 10, 30, 30)];
        [closeBT setImage:[UIImage imageNamed:@"timeline_comment_count_icon"] forState:UIControlStateNormal];
        [closeBT setContentMode:UIViewContentModeCenter];
        [closeBT addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:closeBT];
        
        UIButton *doneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBT setFrame:CGRectMake(290, closeBT.frame.origin.y, closeBT.frame.size.width, closeBT.frame.size.height)];
        [doneBT setImage:[UIImage imageNamed:@"timeline_retweet_count_icon"] forState:UIControlStateNormal];
        [doneBT setContentMode:UIViewContentModeCenter];
        [doneBT addTarget:self action:@selector(didFinishEditing) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:doneBT];
        
        statusView = [[UIView alloc] initWithFrame:CGRectMake(0, barView.frame.size.height, 320, 70)];
//        [statusView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_detail_border"]]];
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
    
    if (operation == StatusOperationRetweet) {
        UIImageView *postThumb = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        [postThumb setContentMode:UIViewContentModeScaleAspectFit];
        NSString *thumbURLString;
        if (post.picURLs && post.picURLs.count > 0) {
            thumbURLString = [post.picURLs objectAtIndex:0];
        }else if (post.retweeted.picURLs && post.retweeted.picURLs.count>0)
            thumbURLString = [post.retweeted.picURLs objectAtIndex:0];
        if (thumbURLString) {
            postThumb.image = [[FHImageCache sharedImage] getImageForURL:thumbURLString];
        }else{
            //defaultImage
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
    [[FHWeiBoAPI sharedWeiBoAPI] retweetStatus:opStatus.ID content:statusTextView.text commentTo:0 interactionProperty:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showTextViewPlaceholder
{
    if (!statusTextViewPlaceholder) {
        statusTextViewPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 15)];
        [statusTextViewPlaceholder setFont:statusTextView.font];
        [statusTextViewPlaceholder setBackgroundColor:[UIColor clearColor]];
        [statusTextView addSubview:statusTextViewPlaceholder];
        [statusTextViewPlaceholder setTextColor:[UIColor lightGrayColor]];
        [statusTextViewPlaceholder setEnabled:NO];
    }
    [statusTextViewPlaceholder setHidden:NO];

    switch (operation) {
        case StatusOperationComment:
            statusTextViewPlaceholder.text = @"待我评论一番";
            break;
        case StatusOperationReply:
            statusTextViewPlaceholder.text = @"回复";
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


@end
