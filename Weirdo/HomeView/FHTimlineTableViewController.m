//
//  FHTimlineTableViewController.m
//  Weirdo
//
//  Created by FengHuan on 14-3-19.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHTimlineTableViewController.h"
#import "FHTimelinePostCell.h"

@interface FHTimlineTableViewController ()
{
    NSMutableArray *posts;
}
@end

@implementation FHTimlineTableViewController

@synthesize category;

- (id)initWithTimeline:(TimelineCategory)timelineCategory
{
    if (self) {
        self = [self initWithStyle:UITableViewStylePlain];
        category = timelineCategory;
        posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DLog(@"category: %d", category);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self pullDownToRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
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
    [self.tableView reloadData];
}

- (void)fetchFailedWithNetworkError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return posts ? posts.count : 0;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHTimelinePostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[FHTimelinePostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
    }
    
    [cell updateCellWithPost:[posts objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FHTimelinePostCell cellHeightWithPost:[posts objectAtIndex:indexPath.row]];
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
