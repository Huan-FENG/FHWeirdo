//
//  FHHomePageViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHHomePageViewController.h"
#import "FHTimelineViewController.h"
#import "SMPageControl.h"
#import "FHUserViewController.h"
#import "FHSettingInfoViewController.h"

@interface FHHomePageViewController ()
{ 
    FHTimelineViewController *VC1;
    FHTimelineViewController *VC2;
    FHTimelineViewController *VC3;
    UIScrollView *titleScroll;
    SMPageControl *pageIndicator;
    TimelineCategory willToVCCategory;
    
    UINavigationController *userInfoVC;
    FHSettingInfoViewController *settingInfoVC;
}

@end

@implementation FHHomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    if (self) {
        self = [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 100, 45)];
        titleScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, customTitle.bounds.size.width, 30)];
        [titleScroll setShowsHorizontalScrollIndicator:NO];
        [titleScroll setShowsVerticalScrollIndicator:NO];
        [titleScroll setContentSize:CGSizeMake(titleScroll.frame.size.width*3, titleScroll.self.frame.size.height)];
        [titleScroll setScrollEnabled:NO];
        for (int i=0; i<3; i++) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100*i, 10, titleScroll.frame.size.width, titleScroll.frame.size.height - 10)];
            [title setTextColor:[UIColor whiteColor]];
            [title setBackgroundColor: [UIColor clearColor]];

            switch (i) {
                case 0:
                    [title setText:@"主 页"];
                    break;
                case 1:
                    [title setText:@"好 友"];
                    break;
                case 2:
                    [title setText:@"发 现"];
                    break;
                default:
                    break;
            }
            [titleScroll addSubview:title];
        }
        pageIndicator = [[SMPageControl alloc] initWithFrame:CGRectMake(titleScroll.frame.origin.x, titleScroll.frame.size.height, titleScroll.frame.size.width, 10)];
        [pageIndicator setIndicatorDiameter:4.0];
        [pageIndicator setIndicatorMargin:5.0];
        [pageIndicator setAlignment:SMPageControlAlignmentCenter];
        [pageIndicator setEnabled:NO];
        
        [pageIndicator setNumberOfPages:3];
        [pageIndicator setCurrentPage:0];
        [customTitle addSubview:titleScroll];
        [customTitle addSubview:pageIndicator];
        [self.navigationItem setTitleView:customTitle];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VC1 = [[FHTimelineViewController alloc] initWithTimeline:TimelineCategoryHome];
    [VC1.view setBackgroundColor:[UIColor whiteColor]];
    [self setViewControllers:@[VC1] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    [self setDataSource:self];
    [self setDelegate:self];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setDelegate:self];
        }
    }
    
    UIButton *userInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userInfoBtn setFrame:CGRectMake(0, 0, (isIOS7?14:14+IOS6_BAR_BUTTOM_PADDING), 16)];
    [userInfoBtn setImage:[UIImage imageNamed:@"userprofile.png"] forState:UIControlStateNormal];
    [userInfoBtn addTarget:self action:@selector(checkUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:userInfoBtn]];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoBtn setFrame:CGRectMake(0, 0, (isIOS7?16:16+IOS6_BAR_BUTTOM_PADDING), 16)];
    [infoBtn setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(checkSettingInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:infoBtn]];
}

- (void)checkSettingInfo
{
    if (!settingInfoVC) {
        settingInfoVC = [[FHSettingInfoViewController alloc] init];
    }
    [self.navigationController pushViewController:settingInfoVC animated:YES];
}

- (void)checkUserInfo
{
    if (!userInfoVC) {
        userInfoVC = [[UINavigationController alloc] initWithRootViewController:[[FHUserViewController alloc] init]];
        userInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentViewController:userInfoVC animated:YES completion:NULL];
}

#pragma mark
#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == self.view.frame.size.width) {
        return;
    }
    DLog(@"x:%.f",scrollView.contentOffset.x);
    CGPoint scrollToPoint;
    if (scrollView.contentOffset.x > self.view.frame.size.width) {
        CGFloat percentage = (scrollView.contentOffset.x - self.view.frame.size.width) / self.view.frame.size.width;
        scrollToPoint = CGPointMake(pageIndicator.currentPage*titleScroll.frame.size.width + percentage*titleScroll.frame.size.width, 0);
    }else{
        CGFloat percentage = (self.view.frame.size.width - scrollView.contentOffset.x) / self.view.frame.size.width;
        scrollToPoint = CGPointMake(pageIndicator.currentPage*titleScroll.frame.size.width - percentage*titleScroll.frame.size.width, 0);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [titleScroll setContentOffset:scrollToPoint animated:YES];
    });
}

#pragma mark
#pragma mark - pageView delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [pageIndicator setCurrentPage:willToVCCategory];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    willToVCCategory = [(FHTimelineViewController *)[pendingViewControllers lastObject] category];
}

#pragma mark
#pragma mark - pageViewController data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *nextVC;
    FHTimelineViewController *timelineVC = (FHTimelineViewController *)viewController;
    switch (timelineVC.category) {
        case TimelineCategoryHome:{
            if (!VC2) {
                VC2 = [[FHTimelineViewController alloc] initWithTimeline:TimelineCategoryFriends];
                [VC2.view setBackgroundColor:[UIColor whiteColor]];
            }
            nextVC = VC2;
            break;
        }
        case TimelineCategoryFriends:{
            if (!VC3) {
                VC3 = [[FHTimelineViewController alloc] initWithTimeline:TimelineCategoryPublic];
                [VC3.view setBackgroundColor:[UIColor whiteColor]];
            }
            nextVC = VC3;
            break;
        }
        default:
            break;
    }
    return nextVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *previousVC;
    FHTimelineViewController *timelineVC = (FHTimelineViewController *)viewController;
    switch (timelineVC.category) {
        case TimelineCategoryFriends:{
            if (!VC1) {
                VC1 = [[FHTimelineViewController alloc] initWithTimeline:TimelineCategoryHome];
                [VC1.view setBackgroundColor:[UIColor whiteColor]];
            }
            previousVC = VC1;
            break;
        }
        case TimelineCategoryPublic:{
            if (!VC2) {
                VC2 =  [[FHTimelineViewController alloc] initWithTimeline:TimelineCategoryFriends];
                [VC2.view setBackgroundColor:[UIColor whiteColor]];
            }
            previousVC = VC2;
        }
        default:
            break;
    }
    return previousVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
