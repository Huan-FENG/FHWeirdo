//
//  FHHomeNavigationController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHHomeNavigationController.h"
#import "FHHomePageViewController.h"

@interface FHHomeNavigationController ()

@end

@implementation FHHomeNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:DEFAULT_COLOR];
    }
    return self;
}

- (id)init
{
    if (self) {
        FHHomePageViewController *pageVC = [[FHHomePageViewController alloc] init];
        self = [self initWithRootViewController:pageVC];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"HOME"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
