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
    pullTableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - ([UIDevice currentDevice].systemVersion.doubleValue<7.0?44:64)) style:UITableViewStylePlain];
    [self.view addSubview:pullTableView];
    [pullTableView setDelegate:self];
    [pullTableView setDataSource:self];
    [pullTableView setPullDelegate:self];
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
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
    if (clickedType == CellClickedTypePictures) {
        return;
    }
    FHOPViewController *opVC = [[FHOPViewController alloc] init];
    switch (clickedType) {
        case CellClickedTypeRetweet:
            [opVC setupWithPost:[posts objectAtIndex:indexPath.row] operation:StatusOperationRetweet];
            NSLog(@"index: %d, retweet", indexPath.row);
            break;
        case CellClickedTypeComment:
            [opVC setupWithPost:[posts objectAtIndex:indexPath.row] operation:StatusOperationComment];
            NSLog(@"index: %d, retcomment", indexPath.row);
            break;
        case CellClickedTypeVote:
            NSLog(@"index: %d, vote", indexPath.row);
            break;
        case CellClickedTypePictures:
            NSLog(@"index: %d, pictures", indexPath.row);
            break;
        case CellClickedTypeUserImage:
            NSLog(@"index: %d, userimage", indexPath.row);
            break;
        default:
            break;
    }
    [self presentViewController:opVC animated:YES completion:NULL];
    needRefresh = NO;
}

- (void)timelinePostCell:(FHTimelinePostCell *)cell didSelectLink:(NSString *)link
{
    DLog(@"link: %@", link);
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
