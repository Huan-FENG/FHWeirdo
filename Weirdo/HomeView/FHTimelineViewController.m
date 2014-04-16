//
//  FHTimelineViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-10.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHTimelineViewController.h"
#import "FHOPViewController.h"
#import "FHPostViewController.h"
#import "FHWebViewController.h"
#import "FHImageScrollView.h"

#define REFRESH_TIMEINTERVAL 15*60

@interface FHTimelineViewController ()
{
    NSMutableArray *posts;
    BOOL needRefresh;
    FHWebViewController *webVC;
}

@end

@implementation FHTimelineViewController

@synthesize pullTableView, category;

- (id)initWithTimeline:(TimelineCategory)timelineCategory
{
    self = [super init];
    if (self) {
        category = timelineCategory;
        posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    needRefresh = YES;
    pullTableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (isIOS7?64:44)) style:UITableViewStylePlain];
    [self.view addSubview:pullTableView];
    [pullTableView setDelegate:self];
    [pullTableView setDataSource:self];
    [pullTableView setPullDelegate:self];
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.pullTableView.pullTableIsRefreshing && needRefresh) {
        self.pullTableView.pullTableIsRefreshing = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (needRefresh) {
        [self pullDownToRefresh];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    needRefresh = NO;
}

- (void)viewDidUnload
{
    [self setPullTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMoreDataToTable
{
    if (!pullTableView.pullTableIsLoadingMore) {
        [self pullUpToRefresh];
    }
}

- (void)pullDownToRefresh
{
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc ] init];
    [property setAfterFailedTarget:self];
    [property setAfterFailedSelector:@selector(fetchFailedWithNetworkError:)];
    [property setAfterFinishedTarget:self];
    [property setAfterFinishedSelector:@selector(fetchNewerFinishedWithResponseDic:)];
    
    FHPost *post = (posts && posts.count > 0) ? [posts objectAtIndex:0] : nil;
    if (pullTableView.pullLastRefreshDate) {
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:pullTableView.pullLastRefreshDate];
        if (interval > REFRESH_TIMEINTERVAL) {
            post = nil;
        }
    }
    
    switch (category) {
        case TimelineCategoryHome:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchHomePostsNewer:YES thanPost:post interactionProperty:property];
            break;
        case TimelineCategoryFriends:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchBilateralPostsNewer:YES thanPost:post interactionProperty:property];
            break;
        case TimelineCategoryPublic:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchPublicPostsWithInteractionProperty:property];
            break;
        default:
            break;
    }
}

- (void)pullUpToRefresh
{
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc ] init];
    [property setAfterFailedTarget:self];
    [property setAfterFailedSelector:@selector(fetchFailedWithNetworkError:)];
    [property setAfterFinishedTarget:self];
    [property setAfterFinishedSelector:@selector(fetchLaterFinishedWithResponseDic:)];
    switch (category) {
        case TimelineCategoryHome:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchHomePostsNewer:NO thanPost:[posts lastObject] interactionProperty:property];
            break;
        case TimelineCategoryFriends:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchBilateralPostsNewer:NO thanPost:[posts lastObject] interactionProperty:property];
            break;
        case TimelineCategoryPublic:
            [[FHWeiBoAPI sharedWeiBoAPI] fetchPublicPostsWithInteractionProperty:property];
            break;
        default:
            break;
    }
}

- (void)fetchNewerFinishedWithResponseDic:(NSDictionary *)responseDic
{
    
    NSArray *postsArray = [responseDic objectForKey:@"statuses"];
    
    NSTimeInterval interval = MAXFLOAT;
    if (pullTableView.pullLastRefreshDate) {
        interval = [[NSDate new] timeIntervalSinceDate:pullTableView.pullLastRefreshDate];
    }
    
    NSMutableArray *freshPosts;
    if (interval > REFRESH_TIMEINTERVAL) {
        freshPosts = [[NSMutableArray alloc] init];
    }else{
        freshPosts = [NSMutableArray arrayWithArray:posts];
    }
    if (postsArray && postsArray.count > 0)
    {
        for (int i = postsArray.count; i>0; i--) {
            NSDictionary *postDic = [postsArray objectAtIndex:i-1];
            FHPost *post = [[FHPost alloc] initWithPostDic:postDic];
            [freshPosts insertObject:post atIndex:0];
        }
        posts = freshPosts;
        [pullTableView reloadData];
    }
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void)fetchLaterFinishedWithResponseDic:(NSDictionary *)responseDic
{
    NSArray *postsArray = [responseDic objectForKey:@"statuses"];
    if (postsArray && postsArray.count > 0) {
        NSMutableArray *freshPosts = [NSMutableArray arrayWithArray:posts];
        for (int i=0; i<postsArray.count; i++) {
            if (i == 0) {
                continue;
            }
            FHPost *post = [[FHPost alloc] initWithPostDic:[postsArray objectAtIndex:i]];
            [freshPosts addObject:post];
        }
        posts = freshPosts;
        [pullTableView reloadData];
    }
    self.pullTableView.pullTableIsLoadingMore = NO;
}

- (void)fetchFailedWithNetworkError:(NSError *)error
{
    self.pullTableView.pullTableIsLoadingMore = NO;
    self.pullTableView.pullTableIsRefreshing = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark
#pragma mark - Table view data source & delagate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return posts ? posts.count : 0;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHTimelinePostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[FHTimelinePostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
    }
    
    [cell updateCellWithPost:[posts objectAtIndex:indexPath.row] isPostOnly:NO];
    [cell setIndexPath:indexPath];
    [cell setDelegate:self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FHTimelinePostCell cellHeightWithPost:[posts objectAtIndex:indexPath.row] isPostOnly:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHPostViewController *postVC = [[FHPostViewController alloc] init];
    [postVC setPost:[posts objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:postVC animated:YES];
}

#pragma mark
#pragma mark - timelinePostCell delegate

- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectAtIndexPath:(NSIndexPath *)indexPath withClickedType:(CellClickedType)clickedType contentIndex:(NSUInteger)index
{

    switch (clickedType) {
        case CellClickedTypeRetweet:{
            FHOPViewController *opVC = [[FHOPViewController alloc] init];
            [opVC setupWithPost:[posts objectAtIndex:indexPath.row] operation:StatusOperationRetweet];
            [self presentViewController:opVC animated:YES completion:NULL];
            break;
        }
        case CellClickedTypeComment:{
            FHOPViewController *opVC = [[FHOPViewController alloc] init];
            [opVC setupWithPost:[posts objectAtIndex:indexPath.row] operation:StatusOperationComment];
            [self presentViewController:opVC animated:YES completion:NULL];
            break;
        }
        case CellClickedTypeVote:
            NSLog(@"index: %d, vote", indexPath.row);
            break;
        case CellClickedTypePictures:
        {
            NSArray *imageURLs;
            FHPost *post = [posts objectAtIndex:indexPath.row];
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
        webVC = [[FHWebViewController alloc] initWithLink:link];
    }else
        [webVC setLink:link];
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark
#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self pullDownToRefresh];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self pullUpToRefresh];
}

@end
