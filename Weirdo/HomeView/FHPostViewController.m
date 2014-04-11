//
//  FHPostViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-4-9.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHPostViewController.h"
#import "FHTimelinePostCell.h"
#import "FHCommentCell.h"
#import "FHOPViewController.h"

@interface FHPostViewController ()
{
    UILabel *title;
    UIView *mainTitleView;
    NSMutableArray *comments;
    BOOL needRefresh;
    
    UILabel *loadMoreLB;
    UIActivityIndicatorView *loadMoreActivity;
}

@end

@implementation FHPostViewController

@synthesize post, postView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        mainTitleView = self.navigationItem.titleView;
        title = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50, 0, 100, 44)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [self.navigationItem setTitleView:title];
        comments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    needRefresh = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    title.text = @"微博正文";
}

- (void)viewDidAppear:(BOOL)animated
{
    if (needRefresh) {
        [self pullDownToRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setTitleView:mainTitleView];
}

- (void)didReceiveMemoryWarning
{
    DLog();
    [super didReceiveMemoryWarning];
}

- (void)pullDownToRefresh
{
    FHConnectionInterationProperty *property = [[FHConnectionInterationProperty alloc ] init];
    [property setAfterFailedTarget:self];
    [property setAfterFailedSelector:@selector(fetchFailedWithNetworkError:)];
    [property setAfterFinishedTarget:self];
    [property setAfterFinishedSelector:@selector(fetchFinishedWithResponseDic:)];
    FHPost *comment = (comments && comments.count > 0) ? [comments lastObject] : nil;
    [[FHWeiBoAPI sharedWeiBoAPI] fetchCommentForStatus:post.ID laterThanComment:comment.ID interactionProperty:property];
}

- (void)fetchFinishedWithResponseDic:(NSDictionary *)responseDic
{
    NSArray *commentsArray = [responseDic objectForKey:@"comments"];
    for (NSDictionary *commentDic in commentsArray) {
        FHPost *comment = [[FHPost alloc] initWithPostDic:commentDic];
        [comments addObject:comment];
    }
    if (commentsArray.count == 0) {
        loadMoreLB.text = @"已无更多评论";
    }
    if (comments) {
        loadMoreLB.text = @"暂无评论";
    }
    [loadMoreActivity stopAnimating];
    needRefresh = YES;
    [self.tableView reloadData];
}

- (void)fetchFailedWithNetworkError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return comments ? comments.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        FHTimelinePostCell *postcell = [tableView dequeueReusableCellWithIdentifier:@"PostViewSectionCell"];
        if (postcell == nil) {
            postcell = [[FHTimelinePostCell alloc] init];
        }
        [postcell updateCellWithPost:post isPostOnly:YES];
        cell = postcell;
    }else{
        FHCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentSectionCell"];
        if (commentCell == nil) {
            commentCell = [[FHCommentCell alloc] init];
        }
        [commentCell updateCellWithComment:[comments objectAtIndex:indexPath.row]];
        cell = commentCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [FHTimelinePostCell cellHeightWithPost:post isPostOnly:YES];
    }else
        return [FHCommentCell cellHeightWithComment:[comments objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    FHOPViewController *opVC = [[FHOPViewController alloc] init];
    [opVC setReplyTo:[[comments objectAtIndex:indexPath.row] username]];
    [opVC setupWithPost:post operation:StatusOperationReply];
    [self presentViewController:opVC animated:YES completion:NULL];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    needRefresh = NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((comments.count == 0 && indexPath.section == 0) || (indexPath.section == 1 && indexPath.row == comments.count-1)) {
        
        if (tableView.tableFooterView) {
            return;
        }
        
        UIView *footerView = [[UIView alloc] init];
        [footerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        loadMoreLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, footerView.frame.size.height)];
        loadMoreLB.center = footerView.center;
        [loadMoreLB setFont:[UIFont systemFontOfSize:10]];
        [loadMoreLB setTextColor:[UIColor lightGrayColor]];
        [loadMoreLB setBackgroundColor:[UIColor clearColor]];
        [loadMoreLB setShadowColor:[UIColor clearColor]];
        loadMoreLB.text = @"获取更多评论";
        [footerView addSubview:loadMoreLB];
        
        loadMoreActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        loadMoreActivity.center = footerView.center;
        CGRect frame = loadMoreActivity.frame;
        frame.origin.x = loadMoreLB.frame.origin.x - 30;
        [loadMoreActivity setFrame:frame];
        [loadMoreActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [footerView addSubview:loadMoreActivity];
        self.tableView.tableFooterView = footerView;
    }
}

@end
