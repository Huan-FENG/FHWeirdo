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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    FHOPViewController *opVC = [[FHOPViewController alloc] init];
    [opVC setReplyTo:[[comments objectAtIndex:indexPath.row] username]];
    [opVC setupWithPost:post operation:StatusOperationReply];
    [self presentViewController:opVC animated:YES completion:NULL];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    needRefresh = NO;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
