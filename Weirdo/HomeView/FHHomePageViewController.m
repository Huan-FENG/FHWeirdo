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
                VC1 = [[UIViewController alloc] init];
                [VC1.view setBackgroundColor:[UIColor whiteColor]];
//                [self.navigationItem setTitle:@"FIRST PAGE"];
                [VC1.view setTag:0];
            }
            previousVC = VC1;
            break;
        }
        case 2:{
            if (!VC2) {
                VC2 = [[UIViewController alloc] init];
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
