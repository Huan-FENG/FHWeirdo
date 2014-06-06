//
//  FHSettingInfoViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-16.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHSettingInfoViewController.h"
#import "FHConnectionLog.h"
#import "FHSUStatusBar.h"
#import <MessageUI/MessageUI.h>

@interface FHSettingInfoViewController ()
{
    UILabel *uploadedSize;
    NSString *update_url;
}
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
    [backBarBtn setFrame:CGRectMake(0, 0, (isIOS7?14:14+IOS6_BAR_BUTTOM_PADDING), 14)];
    [backBarBtn setImage:[UIImage imageNamed:@"navigationbar_backItem.png"] forState:UIControlStateNormal];
    [backBarBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backBarBtn]];
    
    UIImageView *feedbackView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [feedbackView setFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
    UILabel *feedback = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, feedbackView.frame.size.width-20*2-60, 20)];
    feedback.text = @"意见反馈";
    feedback.textAlignment = NSTextAlignmentLeft;
    feedback.backgroundColor = [UIColor clearColor];
    feedback.font = [UIFont systemFontOfSize:11.0];
    [feedbackView addSubview:feedback];
    
    UIButton *emailbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailbutton setFrame:CGRectMake(feedback.frame.origin.x+feedback.frame.size.width, 0, feedbackView.frame.size.height, feedbackView.frame.size.height)];
    [emailbutton setImage:[UIImage imageNamed:@"setting_mail.png"] forState:UIControlStateNormal];
    [emailbutton addTarget:self action:@selector(showMailView) forControlEvents:UIControlEventTouchUpInside];
    [feedbackView addSubview:emailbutton];
    
    UIButton *messagebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messagebutton setFrame:CGRectMake(emailbutton.frame.origin.x+emailbutton.frame.size.width, emailbutton.frame.origin.y, emailbutton.frame.size.width, emailbutton.frame.size.height)];
    [messagebutton setImage:[UIImage imageNamed:@"setting_chat.png"] forState:UIControlStateNormal];
    [messagebutton addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchUpInside];
    
    [feedbackView setUserInteractionEnabled:YES];
    [feedbackView addSubview:messagebutton];
    
    [self.view addSubview:feedbackView];
    
    UIImageView *identifierView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [identifierView setFrame:CGRectMake(0, feedbackView.frame.origin.y + feedbackView.frame.size.height + 10, self.view.frame.size.width, 30)];
    
    UILabel *identifier = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, identifierView.frame.size.width-20*2, 20)];
    identifier.text = [NSString stringWithFormat:@"标志符：%@", [FHConnectionLog logIdentifer]];
    identifier.textAlignment = NSTextAlignmentLeft;
    identifier.backgroundColor = [UIColor clearColor];
    identifier.font = feedback.font;
    [identifierView addSubview:identifier];
    [self.view addSubview:identifierView];
    
    UIImageView *uploadedSizeView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [uploadedSizeView setFrame:CGRectMake(0, identifierView.frame.origin.y + identifierView.frame.size.height + 10, self.view.frame.size.width, 30)];
    uploadedSize = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, uploadedSizeView.frame.size.width-20*2, 20)];
    uploadedSize.textAlignment = NSTextAlignmentLeft;
    uploadedSize.backgroundColor = [UIColor clearColor];
    uploadedSize.font = feedback.font;
    [uploadedSizeView addSubview:uploadedSize];
    [self.view addSubview:uploadedSizeView];
    
    UIImageView *versionView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [versionView setFrame:CGRectMake(0, uploadedSizeView.frame.origin.y + uploadedSizeView.frame.size.height + 10, self.view.frame.size.width, 30)];
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, versionView.frame.size.width-20*2, 20)];
    version.textAlignment = NSTextAlignmentLeft;
    version.backgroundColor = [UIColor clearColor];
    version.font = feedback.font;
    version.text = [NSString stringWithFormat:@"版本号：%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
    [versionView addSubview:version];
    [self.view addSubview:versionView];
    
    UIImageView *announcementView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"setting_detail_border.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:5 ]];
    [announcementView setFrame:CGRectMake(0, versionView.frame.origin.y + versionView.frame.size.height + 10, self.view.frame.size.width, 180)];
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

- (void)viewWillAppear:(BOOL)animated
{
    uploadedSize.text = [NSString stringWithFormat:@"已上传：%@", [self getUploadedDataSize]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self checkVersion];
}

- (NSString *)getUploadedDataSize
{
    NSString *uploadedDataSizeString;
    long long uploadedDataSize = [FHConnectionLog getUploadedSize];
    if (uploadedDataSize) {
        if (uploadedDataSize > 1000) {
            if (uploadedDataSize/(1024.0) > 1000) {
                if (uploadedDataSize/(1024*1024.0) > 1000) {
                    uploadedDataSizeString = [NSString stringWithFormat:@"%.2f GB", uploadedDataSize/(1024*1024*1024.0)];
                }else
                    uploadedDataSizeString = [NSString stringWithFormat:@"%.2f MB", uploadedDataSize/(1024*1024.0)];
            }else
                uploadedDataSizeString = [NSString stringWithFormat:@"%.2f KB", uploadedDataSize/(1024.0)];

        }else
            uploadedDataSizeString = [NSString stringWithFormat:@"%.2lld B", uploadedDataSize];
    }else
        uploadedDataSizeString = @"0 byte";
    return uploadedDataSizeString;
}

- (void)showMessageView
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = [NSArray arrayWithObject:@"13810447856"];
        controller.body = [NSString stringWithFormat:@"用户:%@", [FHConnectionLog logIdentifer]];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:NULL];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"意见反馈"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法发送短信" message:@"设备没有短信功能" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)showMailView
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    [mailPicker setSubject:@"意见反馈"];
    [mailPicker setToRecipients: @[@"fenghuan517@gmail.com"]];
    
    NSString *emailBody = [NSString stringWithFormat:@"用户:%@\n", [FHConnectionLog logIdentifer] ];
    [mailPicker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailPicker animated:YES completion:NULL];
}

- (void)checkVersion
{
    NSDictionary *checkresult = [[FHWeiBoAPI sharedWeiBoAPI] checkVersion];
    if (checkresult) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新版本可用" message:[checkresult objectForKey:@"description"] delegate:self cancelButtonTitle:@"稍后更新" otherButtonTitles:@"前往更新", nil];
        update_url = [checkresult objectForKey:@"trackViewUrl"];
        [alert show];
    }
}

#pragma mark
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    FHSUStatusBar *statusbar = [[FHSUStatusBar alloc] init];
    switch (result) {
        case MFMailComposeResultCancelled:
            [statusbar showStatusMessage: @"取消编辑邮件"];
            break;
        case MFMailComposeResultSaved:
            [statusbar showStatusMessage:@"成功保存邮件"];
            break;
        case MFMailComposeResultSent:
            [statusbar showStatusMessage:@"意见反馈邮件已添至发送列表"];
            break;
        case MFMailComposeResultFailed:
            [statusbar showStatusMessage:@"发送邮件失败"];
            break;
        default:
            break;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    FHSUStatusBar *statusbar = [[FHSUStatusBar alloc] init];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    switch (result) {
        case MessageComposeResultCancelled:
            [statusbar showStatusMessage:@"反馈信息发送取消"];
            break;
        case MessageComposeResultFailed:
            [statusbar showStatusMessage:@"反馈信息发送失败"];
            break;
        case MessageComposeResultSent:
            [statusbar showStatusMessage:@"反馈信息发送中"];
            break;
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (update_url) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:update_url]];
        }
    }
}
@end
