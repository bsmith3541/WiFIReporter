//
//  TestResultsViewController.h
//  WifiReporter
//
//  Created by Brandon Smith on 6/17/13.
//  Copyright (c) 2013 STC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestResultsViewController : UITableViewController
@property(nonatomic) PFObject *lastObj;
@property (weak, nonatomic) IBOutlet UITableViewCell *testInfo;
@property (weak, nonatomic) IBOutlet UITableViewCell *networkInfo;
@property (weak, nonatomic) IBOutlet UITableViewCell *locInfo;
@property (weak, nonatomic) IBOutlet UITableViewCell *trial1;
@property (weak, nonatomic) IBOutlet UITableViewCell *trial2;
@property (weak, nonatomic) IBOutlet UITableViewCell *trial3;
@property (weak, nonatomic) IBOutlet UITableViewCell *average;
@property (weak, nonatomic) IBOutlet UITableViewCell *testDate;
@end
