//
//  FHSettingInfoViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-16.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHSettingInfoViewController.h"
#import "FHConnectionLog.h"

@interface FHSettingInfoViewController ()

@end

@implementation FHSettingInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isIOS7) {
        UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:statusBarView];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50, 20, 100, 44)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    title.text = @"声明";
    [self.navigationItem setTitleView:title];
    
    UIButton *backBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBtn setFrame:CGRectMake(0, 0, 14, 14)];
    [backBarBtn setBackgroundImage:[UIImage imageNamed:@"navigationbar_backItem.png"] forState:UIControlStateNormal];
    [backBarBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIView *backBarBtnBackGround = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backBarBtn.bounds.size.width+10, backBarBtn.bounds.size.height)];
    [backBarBtnBackGround setContentMode:UIViewContentModeCenter];
    [backBarBtnBackGround setBackgroundColor:[UIColor clearColor]];
    [backBarBtnBackGround addSubview:backBarBtn];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backBarBtnBackGround]];
    
    UIImageView *identifierView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [identifierView setFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
    
    UILabel *identifier = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, identifierView.frame.size.width-20*2, 20)];
    identifier.text = [NSString stringWithFormat:@"标志符：%@", [FHConnectionLog logIdentifer]];
    identifier.textAlignment = NSTextAlignmentLeft;
    identifier.backgroundColor = [UIColor clearColor];
    identifier.font = [UIFont systemFontOfSize:11.0];
    [identifierView addSubview:identifier];
    [self.view addSubview:identifierView];
    
    UIImageView *announcementView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [announcementView setFrame:CGRectMake(0, identifierView.frame.size.height + 10, self.view.frame.size.width, 180)];
    UILabel *announcement = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, announcementView.frame.size.width - 20*2, 0)];
    announcement.numberOfLines = 0;
    announcement.shadowColor = [UIColor clearColor];
    announcement.textAlignment = NSTextAlignmentLeft;
    announcement.textColor = [UIColor grayColor];
    announcement.backgroundColor = [UIColor clearColor];
    announcement.font = identifier.font;
    announcement.text = @"感谢您参与清华大学计算机系高性能所关于移动应用用户行为分析研究工作。\n\n在您使用本应用过程中请注意以下事项：\n1. 当不使用应用时，请将其放在后台，切勿关闭！\n2. 请以一个正常用户的心态使用该应用，切勿以找bug为目的乱点乱按！\n3. 如在正常使用过程中出现bug，请向我们反馈。\n声明如下：\n1. 我们将收集您在使用应用过程中的部分行为数据，其中并不包括您的账号密码等隐私信息，事实上，这些隐私数据由新浪管理，我们也无法获得。\n2. 所有搜集的数据都以研究为目的，非商用且不会公开。\n\n最后，再次感谢您对清华大学计算机系研究工作的支持!";
    announcement.lineBreakMode = NSLineBreakByWordWrapping;
    [announcement sizeToFit];
    CGRect frame = announcementView.frame;
    frame.size.height = announcement.frame.size.height+10;
    announcementView.frame = frame;
    [announcementView addSubview:announcement];
    [self.view addSubview:announcementView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
