//
//  FHOPViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-8.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHOPViewController.h"

@interface FHOPViewController ()
{
    UILabel *title;
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
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, barView.frame.size.height)];
        [title setCenter:barView.center];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:16.0]];
        [title setShadowColor:[UIColor lightGrayColor]];
        [title setShadowOffset:CGSizeMake(0.5, 0.5)];
        [title setBackgroundColor: [UIColor clearColor]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [barView addSubview:title];
        
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
        
        statusView = [[UIView alloc] initWithFrame:CGRectMake(0, barView.frame.size.height, 320, 120)];
        [statusView setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:statusView];
        
        statusTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, statusView.frame.size.height, 320, self.view.frame.size.height-statusView.frame.size.height)];
        [statusTextView setFont:[UIFont fontWithName:@"Heiti SC" size:15]];
        [statusTextView setDelegate:self];
        [self.view addSubview:statusTextView];
    }
    return self;
}

- (void)setupWithPost:(FHPost *)post operation:(StatusOperation)statusOperation
{
    operation = statusOperation;
    opStatus = post;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [statusTextView becomeFirstResponder];
    statusTextView.selectedRange = NSMakeRange(0, 0);

    NSString *text;
    if (operation == StatusOperationRetweet) {
        text = [NSString stringWithFormat:@"//@%@:%@", opStatus.username, opStatus.text];
        statusTextView.text = [NSString stringWithFormat:@"//@%@:%@", opStatus.username, opStatus.text];;
    }else
        [self showTextViewPlaceholder];
    
    switch (operation) {
        case StatusOperationWrite:
            title.text = @"撰写微博";
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
}

- (void)didReceiveMemoryWarning
{
    DLog();
    [super didReceiveMemoryWarning];
}

- (void)didFinishEditing
{
    DLog(@"text %@", statusTextView.text);
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
            statusTextViewPlaceholder.text = @"请撰写评论";
            break;
        case StatusOperationWrite:
            statusTextViewPlaceholder.text = @"说点儿什么吧";
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
