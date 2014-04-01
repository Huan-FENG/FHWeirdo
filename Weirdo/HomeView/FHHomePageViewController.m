//
//  FHHomePageViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHHomePageViewController.h"
#import "FHTimlineTableViewController.h"
#import "SMPageControl.h"

@interface FHHomePageViewController ()
{
    FHTimlineTableViewController *VC1;
    FHTimlineTableViewController *VC2;
    FHTimlineTableViewController *VC3;
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
        VC1 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryHome];
//        [self.navigationItem setTitle:@"FIRST PAGE"];
        [VC1.view setBackgroundColor:[UIColor whiteColor]];
        [VC1.view setTag:0];
        [self setViewControllers:@[VC1] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        
        UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 100, 45)];
//        CGRect frame = customTitle.frame;
        UIScrollView *titleScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, customTitle.bounds.size.width, 30)];
        [titleScroll setContentSize:CGSizeMake(titleScroll.frame.size.width*3, titleScroll.self.frame.size.height)];
        for (int i=0; i<3; i++) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100*i, 10, titleScroll.frame.size.width, titleScroll.frame.size.height - 10)];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:[UIFont boldSystemFontOfSize:16.0]];
            [title setShadowColor:[UIColor lightGrayColor]];
            [title setShadowOffset:CGSizeMake(0.5, 0.5)];
            [title setBackgroundColor: [UIColor clearColor]];
            [title setTextAlignment:NSTextAlignmentCenter];

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
        SMPageControl *pageIndicator = [[SMPageControl alloc] initWithFrame:CGRectMake(titleScroll.frame.origin.x, titleScroll.frame.size.height, titleScroll.frame.size.width, 10)];
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
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    // Do any additional setup after loading the view.
}

#pragma mark
#pragma mark - pageViewController data source

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished) {
        DLog(@"pageViewController %d", pageViewController.presentingViewController.view.tag);
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *nextVC;
    FHTimlineTableViewController *timelineVC = (FHTimlineTableViewController *)viewController;
    switch (timelineVC.category) {
        case TimelineCategoryHome:{
            if (!VC2) {
                VC2 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryFriends];
//                [self.navigationItem setTitle:@"SENCOND PAGE"];
                [VC2.view setBackgroundColor:[UIColor blackColor]];
//                [VC2.view setTag:1];
            }
            nextVC = VC2;
            break;
        }
        case TimelineCategoryFriends:{
            if (!VC3) {
                VC3 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryPublic];
//                [self.navigationItem setTitle:@"THIRD PAGE"];
                [VC3.view setBackgroundColor:[UIColor brownColor]];
//                [VC3.view setTag:2];
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
    FHTimlineTableViewController *timelineVC = (FHTimlineTableViewController *)viewController;
    switch (timelineVC.category) {
        case TimelineCategoryFriends:{
            if (!VC1) {
                VC1 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryHome];
                [VC1.view setBackgroundColor:[UIColor whiteColor]];
//                [self.navigationItem setTitle:@"FIRST PAGE"];
//                [VC1.view setTag:0];
            }
            previousVC = VC1;
            break;
        }
        case TimelineCategoryPublic:{
            if (!VC2) {
                VC2 =  [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryFriends];
                [VC2.view setBackgroundColor:[UIColor blackColor]];
//                [VC2.view setTag:1];
            }
            previousVC = VC2;
        }
        default:
            break;
    }
    return previousVC;
}

#pragma mark
#pragma mark - pageView delegate

//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    if (completed) {
//        currentPageNumber = currentPageNumber + 1;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
