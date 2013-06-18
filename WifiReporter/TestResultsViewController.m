//
//  TestResultsViewController.m
//  WifiReporter
//
//  Created by Brandon Smith on 6/17/13.
//  Copyright (c) 2013 STC. All rights reserved.
//

#import "TestResultsViewController.h"

@interface TestResultsViewController ()

@end

@implementation TestResultsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateLabels
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"wifiTest"];
    NSLog(@"%@", query);
    NSLog(@"the last object is %@", self.lastObj);
    NSLog(@"the last object ID is: %@", self.lastObj.objectId);
    PFObject *wifiTest = [query getObjectWithId: self.lastObj.objectId];
    NSLog(@"the wifiTest object is %@", wifiTest);
    // Do something with the returned PFObject in the gameScore variable.
    [self.testInfo.detailTextLabel setText:[wifiTest objectForKey:@"test"]];
    [self.networkInfo.detailTextLabel setText:@"N/A"];
    [self.locInfo.detailTextLabel setText:[NSString stringWithFormat:@"%@, %@",[wifiTest objectForKey:@"longitude"],
        [wifiTest objectForKey:@"latitude"]]];
    NSLog(@"%@", [NSString stringWithFormat:@"%@, %@",
    [wifiTest objectForKey:@"longitude"],
    [wifiTest objectForKey:@"latitude"]]);
    [self.trial1.detailTextLabel setText:[wifiTest objectForKey:@"trial1"]];
    NSLog(@"%@", [wifiTest objectForKey:@"trial1"]);
    [self.trial2.detailTextLabel setText:[wifiTest objectForKey:@"trial2"]];
    NSLog(@"%@", [wifiTest objectForKey:@"trial2"]);
    [self.trial3.detailTextLabel setText:[wifiTest objectForKey:@"trial3"]];
    NSLog(@"%@", [wifiTest objectForKey:@"trial3"]);
    [self.average.detailTextLabel setText:[wifiTest objectForKey:@"average"]];
    NSLog(@"%@", [wifiTest objectForKey:@"average"]);
    [self.testDate.detailTextLabel setText:[NSString stringWithFormat:@"%@",wifiTest.createdAt]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    int score = [[gameScore objectForKey:@"score"] intValue];
//    NSString *playerName = [gameScore objectForKey:@"playerName"];
//    BOOL cheatMode = [[gameScore objectForKey:@"cheatMode"] boolValue];
    
    
    [self updateLabels]; 
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
