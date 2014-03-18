//
//  FHMainViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-18.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHMainViewController.h"

@interface FHMainViewController ()
{
    UIButton *previousSelectedButton;
}

@end

@implementation FHMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *VC1 = [[UIViewController alloc] init];
    [VC1.view setBackgroundColor:[UIColor yellowColor]];
    UIViewController *VC2 = [[UIViewController alloc] init];
    [VC2.view setBackgroundColor:[UIColor redColor]];
    UIViewController *VC3 = [[UIViewController alloc] init];
    [VC3.view setBackgroundColor:[UIColor lightGrayColor]];
    [self setViewControllers:@[VC1, VC2, VC3]];
    [self customTabBar];
	// Do any additional setup after loading the view.
}

- (void)customTabBar
{
    [self.tabBar setHidden:YES];
    float tabBarH = 30;
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-tabBarH, self.view.bounds.size.width, tabBarH)];
    [tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg.png"]];
    
    for (int i = 0; i<3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        CGFloat buttonW = tabBar.frame.size.width/3;
        CGFloat buttonH = tabBar.frame.size.height;
        button.frame = CGRectMake(buttonW*i, 0, buttonW, buttonH);
        
        UIImage *normalImage;
        UIImage *selectedImage;
        switch (i) {
            case 0:
                normalImage = [UIImage imageNamed:@"home"];
                selectedImage = [UIImage imageNamed:@"home_selected"];
                break;
            case 1:
                normalImage = [UIImage imageNamed:@"message"];
                selectedImage = [UIImage imageNamed:@"message_selected"];
                break;
            case 2:
                normalImage = [UIImage imageNamed:@"profile"];
                selectedImage = [UIImage imageNamed:@"profile_selected"];
                break;
            default:
                break;
        }
        
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectedImage forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventTouchDown];
        button.imageView.contentMode = UIViewContentModeCenter;
        [tabBar addSubview:button];
    }
    [self.view addSubview:tabBar];
    
    UIView *transitionView = [[self.view subviews] objectAtIndex:0];
    CGRect transitionViewFrame = transitionView.frame;
    transitionViewFrame.size.height = self.view.frame.size.height - tabBarH;
    [transitionView setFrame:transitionViewFrame];
}

- (void)changeViewController:(UIButton *)sender
{
    self.selectedIndex = sender.tag; //切换不同控制器的界面
    sender.enabled = NO;
    if (previousSelectedButton != sender) {
        previousSelectedButton.enabled = YES;
    }
    previousSelectedButton = sender;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
