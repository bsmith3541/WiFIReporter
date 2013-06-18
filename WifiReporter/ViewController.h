//
//  ViewController.h
//  WifiReporter
//
//  Created by Brandon Smith on 6/11/13.
//  Copyright (c) 2013 STC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    BOOL running;
    NSTimeInterval startTime;
    NSTimeInterval endTime;
    double trialTime;
    double trialBandwidth;
    int trial;
    double trial1;
    double trial2;
    double trial3;
    double average;
}
@property (weak, nonatomic) IBOutlet UILabel *network;
@property (weak, nonatomic) IBOutlet UILabel *testNotice;
@property (weak, nonatomic) IBOutlet UILabel *trial1;
@property (weak, nonatomic) IBOutlet UILabel *trial2;
@property (weak, nonatomic) IBOutlet UILabel *trial3;
@property (weak, nonatomic) IBOutlet UILabel *avg;
@property (weak, nonatomic) IBOutlet UILabel *loc;
@property (strong, nonatomic) PFObject *trialObj;
- (IBAction)btnPressed:(id)sender;
@end
