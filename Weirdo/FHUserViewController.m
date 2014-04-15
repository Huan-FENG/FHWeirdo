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
#import <QuartzCore/QuartzCore.h>

#define SCROLLVIEW_USER_PROFILE 1

@interface FHUserViewController ()
{
    FHUser *user;
    SMPageControl *pageIndicator;
    UIView *mainTitleView;
    UITableView *userStatus;
    UILabel *loadMoreLB;
    UIActivityIndicatorView *loadMoreActivity;
    NSMutableArray *statuses;
    
    UIImageView *userImageView;
    UILabel *userName;
    UILabel *descriptionLB;
    UILabel *statusCount;
    UILabel *friendCount;
    UILabel *followerCount;
    BOOL needRefresh;
}

@end

@implementation FHUserViewController

- (id)initWithUserID:(NSString *)userID
{
    self = [super init];
    if (self) {
        user = [[FHUsers sharedUsers] getUserForID:userID];
        statuses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainTitleView = self.navigationItem.titleView;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50, 0, 100, 44)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    title.text = @"个人资料";
    [self.navigationItem setTitleView:title];
    
    userStatus = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [userStatus setDataSource:self];
    [userStatus setDelegate:self];
    [self.view addSubview:userStatus];
}

- (UIView *)setUserProfileView
{
    UIView *userProfile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    [userProfile setBackgroundColor:DEFAULT_COLOR];
    
    UIScrollView *profileScroll = [[UIScrollView alloc] initWithFrame:userProfile.bounds];
    profileScroll.tag = SCROLLVIEW_USER_PROFILE;
    [profileScroll setContentSize:CGSizeMake(2*profileScroll.frame.size.width, profileScroll.frame.size.height)];
    [profileScroll setPagingEnabled:YES];
    [profileScroll setShowsHorizontalScrollIndicator:NO];
    [profileScroll setShowsVerticalScrollIndicator:NO];
    [profileScroll setDelegate:self];
    
    UIView *userWithImage = [[UIView alloc] initWithFrame:profileScroll.bounds];
    userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(userWithImage.bounds.size.width/2-20, userWithImage.bounds.size.height/2-40, 40, 40)];
    [userImageView setImage:user.profileImage];
    [userImageView.layer setCornerRadius:5.0];
    [userImageView setClipsToBounds:YES];
    [userImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [userImageView.layer setBorderWidth:2.0];
    [userWithImage addSubview:userImageView];
    userName = [[UILabel alloc] initWithFrame:CGRectMake(50, userImageView.frame.origin.y+userImageView.frame.size.height + 5, userWithImage.frame.size.width-100, 30)];
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
    
    [userProfile addSubview:profileScroll];
    [userProfile addSubview:pageIndicator];
    
    UIImageView *detailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, userProfile.frame.size.height, userProfile.frame.size.width, 35)];
    [detailView setImage:[[UIImage imageNamed:@"timeline_detail_border.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:6]];
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

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.titleView = mainTitleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag != SCROLLVIEW_USER_PROFILE) {
        if(!loadMoreActivity.isAnimating && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))){
            [loadMoreActivity startAnimating];
            loadMoreLB.text = @"获取中...";
//            [self pullDownToRefresh];
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
        }
        [cell.contentView addSubview:[self setUserProfileView]];
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
        return 120+35;
    }else
        return [FHTimelinePostCell cellHeightWithPost:[statuses objectAtIndex:indexPath.row] isPostOnly:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
