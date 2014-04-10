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

@interface FHTimelineViewController ()
{
    NSMutableArray *posts;
    BOOL needRefresh;
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
    self.pullTableView.pullBackgroundColor = [UIColor yellowColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if(!self.pullTableView.pullTableIsRefreshing) {
        self.pullTableView.pullTableIsRefreshing = YES;
        [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3.0f];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (needRefresh) {
        [self pullDownToRefresh];
    }
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

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
    [self.pullTableView reloadData];
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.pullTableView.pullTableIsLoadingMore = NO;
}

- (void)pullDownToRefresh
{
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc ] init];
    [property setAfterFailedTarget:self];
    [property setAfterFailedSelector:@selector(fetchFailedWithNetworkError:)];
    [property setAfterFinishedTarget:self];
    [property setAfterFinishedSelector:@selector(fetchFinishedWithResponseDic:)];
    FHPost *post = (posts && posts.count > 0) ? [posts objectAtIndex:0] : nil;
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
    [property setAfterFinishedSelector:@selector(fetchFinishedWithResponseDic:)];
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

- (void)fetchFinishedWithResponseDic:(NSDictionary *)responseDic
{
    NSArray *postsArray = [responseDic objectForKey:@"statuses"];
    for (NSDictionary *postDic in postsArray) {
        FHPost *post = [[FHPost alloc] initWithPostDic:postDic];
        [posts addObject:post];
    }
    [pullTableView reloadData];
}

- (void)fetchFailedWithNetworkError:(NSError *)error
{
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
        default:
            break;
    }
    [self presentViewController:opVC animated:YES completion:NULL];
    needRefresh = NO;
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:3.0f];
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
