//
//  FHUserViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-15.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHUserViewController.h"
#import "FHUsers.h"
#import "SMPageControl.h"
#import "FHPostViewController.h"
#import "FHOPViewController.h"
#import "FHImageScrollView.h"
#import "FHWebViewController.h"
#import "FHFirstViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SCROLLVIEW_USER_PROFILE 1

@interface FHUserViewController ()
{
    FHUser *user;
    SMPageControl *pageIndicator;
    UITableView *userStatus;
    UILabel *loadMoreLB;
    UIActivityIndicatorView *loadMoreActivity;
    UIButton *updateBarBtn;
    UIButton *updateViewBtn;
    NSMutableArray *statuses;
    
    UIImageView *userImageView;
    UILabel *userName;
    UILabel *descriptionLB;
    UILabel *statusCount;
    UILabel *friendCount;
    UILabel *followerCount;
    BOOL needRefresh;
    BOOL showNavigationBar;
    
    FHWebViewController *webVC;
}

@end

@implementation FHUserViewController

- (id)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        statuses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float topPadding = 0;
    if (isIOS7) {
        UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, topPadding)];
        statusBarView.backgroundColor=[UIColor blackColor];
        [self.view addSubview:statusBarView];
        topPadding = 20;
    }
    userStatus = [[UITableView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.bounds.size.width, self.view.bounds.size.height - topPadding) style:UITableViewStylePlain];
    [userStatus setDataSource:self];
    [userStatus setDelegate:self];
    [self.view addSubview:userStatus];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50, 0, 100, 44)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    title.text = @"个人主页";
    [self.navigationItem setTitleView:title];
    
    UIButton *backBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBarBtn setFrame:CGRectMake(0, 0, (isIOS7?14:14+IOS6_BAR_BUTTOM_PADDING), 14)];
    [backBarBtn setImage:[UIImage imageNamed:@"navigationbar_backItem.png"] forState:UIControlStateNormal];
    [backBarBtn addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backBarBtn]];
    
    updateBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBarBtn setFrame:CGRectMake(0, 0, (isIOS7?14:14+IOS6_BAR_BUTTOM_PADDING), 14)];
    [updateBarBtn setImage:[UIImage imageNamed:@"navigationbar_updateItem.png"] forState:UIControlStateNormal];
    [updateBarBtn addTarget:self action:@selector(updateStatuses) forControlEvents:UIControlEventTouchUpInside];
    UIActivityIndicatorView *updateActivityInBar = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [updateActivityInBar setFrame:CGRectMake(0, 0, 15, 15)];
    [updateBarBtn addSubview:updateActivityInBar];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:updateBarBtn]];
    
    needRefresh = YES;
    showNavigationBar = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = !showNavigationBar;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self pullDownToRefresh:needRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateButtonAnimate:(BOOL)animate
{
    if (animate) {
        [updateBarBtn setImage:nil forState:UIControlStateNormal];
        [updateBarBtn setUserInteractionEnabled:NO];
        [updateViewBtn setImage:nil forState:UIControlStateNormal];
        [updateViewBtn setUserInteractionEnabled:NO];
    }else{
        [updateBarBtn setImage:[UIImage imageNamed:@"navigationbar_updateItem.png"] forState:UIControlStateNormal];
        [updateBarBtn setUserInteractionEnabled:YES];
        [updateViewBtn setImage:[UIImage imageNamed:@"navigationbar_updateItem.png"] forState:UIControlStateNormal];
        [updateViewBtn setUserInteractionEnabled:YES];
    }
    
    for (id activity in updateBarBtn.subviews) {
        if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
            if (animate) {
                [activity startAnimating];
            }else
                [activity stopAnimating];
        }
    }
    for (id activity in updateViewBtn.subviews) {
        if ([activity isKindOfClass:[UIActivityIndicatorView class]]) {
            if (animate) {
                [activity startAnimating];
            }else
                [activity stopAnimating];
        }
    }
}

- (UIView *)setUserProfileView
{
    UIView *userProfile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [userProfile setBackgroundColor:DEFAULT_COLOR];
    
    UIScrollView *profileScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, userProfile.frame.size.width, userProfile.frame.size.height)];
    profileScroll.tag = SCROLLVIEW_USER_PROFILE;
    [profileScroll setContentSize:CGSizeMake(2*profileScroll.frame.size.width, profileScroll.frame.size.height)];
    [profileScroll setPagingEnabled:YES];
    [profileScroll setShowsHorizontalScrollIndicator:NO];
    [profileScroll setShowsVerticalScrollIndicator:NO];
    [profileScroll setDelegate:self];
    
    UIView *userWithImage = [[UIView alloc] initWithFrame:profileScroll.bounds];
    userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(userWithImage.bounds.size.width/2-20, userWithImage.bounds.size.height/2-35, 40, 40)];
    [userImageView setImage:user.profileImage];
    [userImageView.layer setCornerRadius:5.0];
    [userImageView setClipsToBounds:YES];
    [userImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [userImageView.layer setBorderWidth:2.0];
    [userWithImage addSubview:userImageView];
    userName = [[UILabel alloc] initWithFrame:CGRectMake(50, userImageView.frame.origin.y+userImageView.frame.size.height, userWithImage.frame.size.width-100, 30)];
    [userName setBackgroundColor:[UIColor clearColor]];
    [userName setTextColor:[UIColor whiteColor]];
    [userName setFont:[UIFont systemFontOfSize:12.0]];
    userName.text = user.name;
    [userWithImage addSubview:userName];
    [profileScroll addSubview:userWithImage];
    
    UIView *description = [[UIView alloc] initWithFrame:CGRectMake(profileScroll.frame.size.width, 0, profileScroll.frame.size.width, profileScroll.frame.size.height)];
    [description setBackgroundColor:[UIColor clearColor]];
    descriptionLB = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, description.frame.size.width - 80, 0)];
    [descriptionLB setBackgroundColor:[UIColor clearColor]];
    descriptionLB.text = user.description;
    if (!descriptionLB.text || descriptionLB.text.length == 0) {
        descriptionLB.text = @"暂无简介";
    }
    [descriptionLB setFont:userName.font];
    [descriptionLB setTextColor:userName.textColor];
    [descriptionLB setNumberOfLines:5];
    [descriptionLB sizeToFit];
    CGRect frame = descriptionLB.frame;
    frame.origin.y = (description.frame.size.height - 10 - descriptionLB.frame.size.height)/2;
    frame.origin.x = (description.frame.size.width - descriptionLB.frame.size.width)/2;
    [descriptionLB setFrame:frame];
    [description addSubview:descriptionLB];
    [profileScroll addSubview:description];
    
    pageIndicator = [[SMPageControl alloc] initWithFrame:CGRectMake(0, userProfile.frame.size.height - 20, userProfile.frame.size.width, 10)];
    [pageIndicator setIndicatorDiameter:4.0];
    [pageIndicator setIndicatorMargin:5.0];
    [pageIndicator setAlignment:SMPageControlAlignmentCenter];
    [pageIndicator setEnabled:NO];
    [pageIndicator setNumberOfPages:2];
    [pageIndicator setCurrentPage:0];
    
    UIButton *backViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backViewBtn setFrame:CGRectMake(15, 15, 24, 14)];
    [backViewBtn setImage:[UIImage imageNamed:@"navigationbar_backItem.png"] forState:UIControlStateNormal];
    [backViewBtn addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    updateViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateViewBtn setFrame:CGRectMake(275, 15, 24, 14)];
    [updateViewBtn setImage:nil forState:UIControlStateNormal];
    [updateViewBtn addTarget:self action:@selector(updateStatuses) forControlEvents:UIControlEventTouchUpInside];
    UIActivityIndicatorView *updateActivityInView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [updateActivityInView setFrame:CGRectMake(0, 0, 15, 15)];
    [updateActivityInView startAnimating];
    [updateViewBtn addSubview:updateActivityInView];
    
    [userProfile addSubview:profileScroll];
    [userProfile addSubview:pageIndicator];
    [userProfile addSubview:backViewBtn];
    [userProfile addSubview:updateViewBtn];
    
    UIImageView *detailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, userProfile.frame.size.height, userProfile.frame.size.width, 35)];
    [detailView setImage:[[UIImage imageNamed:@"userprofile_detail_border.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:6]];
    for (int i = 0; i<3; i++) {
        CGRect frame = CGRectMake(i*(detailView.frame.size.width/3), 1, detailView.frame.size.width/3, 15);
        UILabel *count = [[UILabel alloc] initWithFrame:frame];
        [count setFont:[UIFont systemFontOfSize:12.0]];
        [count setBackgroundColor:[UIColor clearColor]];
        [count setTextColor:DEFAULT_TEXTCOLOR];
        [count setShadowColor:[UIColor clearColor]];
        frame.origin.y = frame.origin.y + frame.size.height+1;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setTextColor:count.textColor];
        [label setFont:count.font];
        [label setShadowColor:count.shadowColor];
        
        switch (i) {
            case 0:
                count.text = [NSString stringWithFormat:@"%d", user.postsCount.intValue];
                label.text = @"微博";
                statusCount = count;
                break;
            case 1:
                count.text = [NSString stringWithFormat:@"%d", user.friendsCount.intValue];
                label.text = @"朋友";
                friendCount = count;
                break;
            case 2:
                count.text = [NSString stringWithFormat:@"%d", user.followersCount.intValue];
                label.text = @"关注";
                followerCount = count;
                break;
            default:
                break;
        }
        [detailView addSubview:count];
        [detailView addSubview:label];
    }
    
    UIView *profileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120+35)];
    [profileView addSubview:userProfile];
    [profileView addSubview:detailView];
    return profileView;
}

- (void)updateUserProfileView
{
    NSError *error;
    user = [[FHUsers sharedUsers] getCurrentUser];
    if (!error) {
        if (!user.profileImage) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUserProfileImage:) userInfo:nil repeats:YES];
        }else
            [userImageView setImage:user.profileImage];
        userName.text = user.name;
        descriptionLB.text = user.description;
        if (!descriptionLB.text || descriptionLB.text.length == 0) {
            descriptionLB.text = @"暂无简介";
        }
        statusCount.text = [NSString stringWithFormat:@"%d", user.postsCount.intValue];
        friendCount.text = [NSString stringWithFormat:@"%d", user.friendsCount.intValue];
        followerCount.text = [NSString stringWithFormat:@"%d", user.followersCount.intValue];
        [userStatus reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updateUserProfileImage:(NSTimer *)timer
{
    user = [[FHUsers sharedUsers] getCurrentUser];
    if (user.profileImage) {
        [userImageView setImage:user.profileImage];
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateStatuses
{
    [self pullDownToRefresh:YES];
}

- (void)pullDownToRefresh:(BOOL)isUpdate
{
    if (isUpdate) {
        [self updateButtonAnimate:YES];
    }
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc ] init];
    [property setAfterFailedTarget:self];
    [property setAfterFailedSelector:@selector(fetchFailedWithNetworkError:)];
    [property setAfterFinishedTarget:self];
    if (!isUpdate) {
        [property setAfterFinishedSelector:@selector(fetchFinishedWithResponseDic:)];
    }else
        [property setAfterFinishedSelector:@selector(updateFinishedWithResponseDic:)];
    
    
    FHPost *status = (!isUpdate && statuses && statuses.count > 0) ? [statuses lastObject] : nil;
    [[FHWeiBoAPI sharedWeiBoAPI] fetchUserPostsLaterThanPost:status interactionProperty:property];
}

- (void)fetchFailedWithNetworkError:(NSError *)error
{
    [self updateButtonAnimate:NO];
    
    loadMoreLB.text = @"获取失败";
    [loadMoreActivity stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:error.localizedDescription delegate:self cancelButtonTitle:@"知道啦" otherButtonTitles:nil, nil];
    alert.tag = ERROR_TOKEN_INVALID;
    [alert show];
}

- (void)fetchFinishedWithResponseDic:(NSDictionary *)responseDic
{
    NSArray *statusArray = [responseDic objectForKey:@"statuses"];
    
    NSMutableArray *freshStatuses;
    freshStatuses = [NSMutableArray arrayWithArray:statuses];
    
    if (statusArray && statusArray.count > 0)
    {
        for (int i = 0; i < statusArray.count; i++) {
            if (freshStatuses.count != 0 && i == 0) {
                continue;
            }
            FHPost *status = [[FHPost alloc] initWithPostDic:[statusArray objectAtIndex:i]];
            [freshStatuses addObject:status];
        }
    
        statuses = freshStatuses;
        [userStatus reloadData];
    }
    [self updateUserProfileView];
}

- (void)updateFinishedWithResponseDic:(NSDictionary *)responseDic
{
    [self updateButtonAnimate:NO];
    NSArray *statusArray = [responseDic objectForKey:@"statuses"];
    NSMutableArray *freshStatuses = [[NSMutableArray alloc] init];
    for (NSDictionary *statusDic in statusArray) {
        FHPost *status = [[FHPost alloc] initWithPostDic:statusDic];
        [freshStatuses addObject:status];
    }
    statuses = freshStatuses;
    [userStatus reloadData];
    [self updateUserProfileView];
}

#pragma mark
#pragma mark - scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == SCROLLVIEW_USER_PROFILE) {
        if (scrollView.contentOffset.x < scrollView.frame.size.width) {
            [pageIndicator setCurrentPage:0];
        }else
            [pageIndicator setCurrentPage:1];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag != SCROLLVIEW_USER_PROFILE) {
        if (scrollView.contentOffset.y > 100-44 && self.navigationController.navigationBarHidden) {
            showNavigationBar = YES;
            self.navigationController.navigationBarHidden = !showNavigationBar;
            CGRect frame = userStatus.frame;
            frame.origin.y = frame.origin.y - (isIOS7?64:44);
            userStatus.frame = frame;
        }
        if (scrollView.contentOffset.y < 100-44 && !self.navigationController.navigationBarHidden) {
            showNavigationBar = NO;
            self.navigationController.navigationBarHidden = !showNavigationBar;
            CGRect frame = userStatus.frame;
            frame.origin.y = frame.origin.y + (isIOS7?64: 44);
            userStatus.frame = frame;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag != SCROLLVIEW_USER_PROFILE) {
        if(!loadMoreActivity.isAnimating && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))){
            [loadMoreActivity startAnimating];
            loadMoreLB.text = @"获取中...";
            [self pullDownToRefresh:NO];
        }
    }
}

#pragma mark
#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return statuses ? statuses.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserProfileCell"];
            [cell.contentView addSubview:[self setUserProfileView]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else{
        FHTimelinePostCell *statusCell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        if (statusCell == nil) {
            statusCell = [[FHTimelinePostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"statusCell"];
        }
        [statusCell updateCellWithPost:[statuses objectAtIndex:indexPath.row] isPostOnly:NO];
        [statusCell setIndexPath:indexPath];
        [statusCell setDelegate:self];
        cell = statusCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100+35;
    }else
        return [FHTimelinePostCell cellHeightWithPost:[statuses objectAtIndex:indexPath.row] isPostOnly:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    FHPostViewController *postVC = [[FHPostViewController alloc] init];
    [postVC setPost:[statuses objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:postVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    needRefresh = NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((statuses.count == 0 && indexPath.section == 0) || (indexPath.section == 1 && indexPath.row == statuses.count-1)) {

        if (tableView.tableFooterView) {
            if (statuses.count == 0 && indexPath.section == 0) {
                loadMoreLB.text = @"正在获取微博...";
            }else
                loadMoreLB.text = @"获取更多微博";
            return;
        }
        
        UIView *footerView = [[UIView alloc] init];
        [footerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        loadMoreLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, footerView.frame.size.height)];
        loadMoreLB.center = footerView.center;
        [loadMoreLB setFont:[UIFont systemFontOfSize:10]];
        [loadMoreLB setTextColor:[UIColor lightGrayColor]];
        [loadMoreLB setBackgroundColor:[UIColor clearColor]];
        [loadMoreLB setShadowColor:[UIColor clearColor]];
        
        if (statuses.count == 0 && indexPath.section == 0) {
            loadMoreLB.text = @"正在获取微博...";
        }else
            loadMoreLB.text = @"获取更多微博";
        [footerView addSubview:loadMoreLB];
        
        loadMoreActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        loadMoreActivity.center = footerView.center;
        CGRect frame = loadMoreActivity.frame;
        frame.origin.x = loadMoreLB.frame.origin.x - 30;
        [loadMoreActivity setFrame:frame];
        [loadMoreActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [footerView addSubview:loadMoreActivity];
        tableView.tableFooterView = footerView;
    }
}

#pragma mark
#pragma mark - timelinePostCell delegate

- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectAtIndexPath:(NSIndexPath *)indexPath withClickedType:(CellClickedType)clickedType contentIndex:(NSUInteger)index
{
    
    switch (clickedType) {
        case CellClickedTypeRetweet:{
            FHOPViewController *opVC = [[FHOPViewController alloc] init];
            [opVC setupWithPost:[statuses objectAtIndex:indexPath.row] operation:StatusOperationRetweet];
            [self presentViewController:opVC animated:YES completion:NULL];
            break;
        }
        case CellClickedTypeComment:{
            FHOPViewController *opVC = [[FHOPViewController alloc] init];
            [opVC setupWithPost:[statuses objectAtIndex:indexPath.row] operation:StatusOperationComment];
            [self presentViewController:opVC animated:YES completion:NULL];
            break;
        }
        case CellClickedTypeVote:
            NSLog(@"index: %d, vote", (int)indexPath.row);
            break;
        case CellClickedTypePictures:
        {
            NSArray *imageURLs;
            FHPost *post = [statuses objectAtIndex:indexPath.row];
            if (post.picURLs.count > 0) {
                imageURLs = post.picURLs;
            }else
                imageURLs = post.retweeted.picURLs;
            if (index < imageURLs.count) {
                FHImageScrollView *imageScrollView = [[FHImageScrollView alloc] initWithImageURLs:imageURLs currentIndex:index];
                [self.navigationController.view addSubview:imageScrollView];
                [imageScrollView show];
            }
            break;
        }
        case CellClickedTypeUserImage:
            break;
        default:
            break;
    }
    needRefresh = NO;
}

- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectLink:(NSString *)link
{
    if (!webVC) {
        webVC = [[FHWebViewController alloc] initWithLink:link] ;
    }else
        [webVC setLink:link];
    [self.navigationController pushViewController:webVC animated:YES];
    needRefresh = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark
#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ERROR_TOKEN_INVALID) {
        FHFirstViewController *relogin = [[FHFirstViewController alloc] init];
        relogin.reLogin = YES;
        [self presentViewController:relogin animated:YES completion:NULL];
    }
}
@end
