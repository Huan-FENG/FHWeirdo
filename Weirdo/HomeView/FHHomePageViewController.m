//
//  FHHomePageViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHHomePageViewController.h"
#import "FHTimlineTableViewController.h"

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
        VC1 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryFriends];
//        [self.navigationItem setTitle:@"FIRST PAGE"];
        [VC1.view setBackgroundColor:[UIColor whiteColor]];
        [VC1.view setTag:0];
        [self setViewControllers:@[VC1] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        
        UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 100, 45)];
        CGRect frame = customTitle.frame;
        UIScrollView *titleScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, customTitle.bounds.size.width, 30)];
        [titleScroll setContentSize:CGSizeMake(titleScroll.frame.size.width*3, titleScroll.self.frame.size.height)];
        for (int i=0; i<3; i++) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100*i, 0, titleScroll.frame.size.width, titleScroll.frame.size.height)];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:[UIFont boldSystemFontOfSize:15.0]];
            [title setShadowColor:[UIColor lightGrayColor]];
            [title setShadowOffset:CGSizeMake(0.5, 0.5)];
            [title setBackgroundColor: [UIColor clearColor]];
            [title setTextAlignment:NSTextAlignmentCenter];
            [title setContentMode:UIViewContentModeBottom];
        
            switch (i) {
                case 0:
                    [title setText:@"主页"];
                    break;
                case 1:
                    [title setText:@"发现"];
                    break;
                case 2:
                    [title setText:@"原创"];
                    break;
                default:
                    break;
            }
            [titleScroll addSubview:title];
        }
        UIPageControl *pageIndicator = [[UIPageControl alloc] initWithFrame:CGRectMake(titleScroll.center.x, titleScroll.frame.size.height, 0, 0)];
        CGRect theframe = pageIndicator.frame;
//        [pageIndicator setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
//        [pageIndicator setPageIndicatorTintColor:[UIColor lightGrayColor]];
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
        DLog(@"%d", pageViewController.presentingViewController.view.tag);
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *nextVC;
    switch (viewController.view.tag) {
        case 0:{
            if (!VC2) {
                VC2 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryPublic];
//                [self.navigationItem setTitle:@"SENCOND PAGE"];
                [VC2.view setBackgroundColor:[UIColor blackColor]];
                [VC2.view setTag:1];
            }
            nextVC = VC2;
            break;
        }
        case 1:{
            if (!VC3) {
                VC3 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryOringal];
//                [self.navigationItem setTitle:@"THIRD PAGE"];
                [VC3.view setBackgroundColor:[UIColor brownColor]];
                [VC3.view setTag:2];
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
    switch (viewController.view.tag) {
        case 1:{
            if (!VC1) {
                VC1 = [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryFriends];
                [VC1.view setBackgroundColor:[UIColor whiteColor]];
//                [self.navigationItem setTitle:@"FIRST PAGE"];
                [VC1.view setTag:0];
            }
            previousVC = VC1;
            break;
        }
        case 2:{
            if (!VC2) {
                VC2 =  [[FHTimlineTableViewController alloc] initWithTimeline:TimelineCategoryPublic];
                [VC2.view setBackgroundColor:[UIColor blackColor]];
                [VC2.view setTag:1];
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
