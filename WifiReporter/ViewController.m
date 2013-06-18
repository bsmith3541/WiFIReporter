//
//  ViewController.m
//  WifiReporter
//
//  Created by Brandon Smith on 6/11/13.
//  Copyright (c) 2013 STC. All rights reserved.
//  Stopwatch code: http://www.techrepublic.com/blog/ios-app-builder/create-your-own-iphone-stopwatch-app/138
// MAC Address Code: http://stackoverflow.com/questions/677530/how-can-i-programmatically-get-the-mac-address-of-an-iphone
// get SSID code from: http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library/5198968#5198968
// checking for active wi-fi network: http://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-iphone-sdk

#import "ViewController.h"
#import "TestResultsViewController.h"
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include "Reachability.h"
#include <SystemConfiguration/SystemConfiguration.h>
#include <SystemConfiguration/CaptiveNetwork.h>

#define IFT_ETHER 0x6 // used in get MAC address method

@interface ViewController ()
@property(nonatomic, strong) NSString *currTestName;
@property(nonatomic, strong) UIButton *currTest;
@property(nonatomic) double bandwidthTotal; // stores the value of the bandwidth
@property(nonatomic) double totalTime;
@property(nonatomic) double lat;
@property(nonatomic) double longitude;
@property(nonatomic, weak) NSString * macAddress;
@property(nonatomic) BOOL locFlag;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"////////////LET'S GET GOING//////////////");
    // initialize variables
    self.bandwidthTotal = 0.0;
    
    // check for wi-fi connection
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
        //Code to execute if WiFi is not connected
        NSLog(@"Helloooo, you're not on wi-fi!");
        
       // display alert if user is not connected to wifi
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to a wi-fi network to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Connected to wi-fi!");
        NSLog(@"The network is %@",[self fetchSSIDInfo]);
    }
    
    running = false;
    
    // query current location
    dispatch_queue_t findLoc = dispatch_queue_create("querying location", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(findLoc, ^{
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                NSLog(@"I see you movin' out there!");
                NSLog(@"In fact, you're at %.3f, %.3f", geoPoint.latitude, geoPoint.longitude);
                self.lat = geoPoint.latitude;
                self.longitude = geoPoint.longitude;
                self.locFlag = YES;
            } else {
                [self.loc setText:@"Location: Error obtaining location"];
                self.locFlag = NO;
            }
        }];
    });
    
    
    // get MAC address
    char* macAddressString= (char*)malloc(18);
    NSString* macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString, "en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    self.macAddress = macAddress;
    free(macAddressString);
    NSLog(@"The MAC address is: %@", self.macAddress);
    
}


- (IBAction)btnPressed:(UIButton *)sender
{
    // iterative stepper
    if (running == false)
    {
        dispatch_queue_t runTrials = dispatch_queue_create("run tests", NULL);
        dispatch_sync(runTrials, ^{
        int i;
        // start the test
        running = true;
        
        // update current test info
        self.currTestName = sender.currentTitle;
        self.currTest = sender;
        
        [sender setHighlighted:NO];
        sender.userInteractionEnabled = NO;
        if(self.locFlag == YES)
        {
            [self.loc setText:[NSString stringWithFormat:@"Location: %.3f, %.3f", self.lat, self.longitude]];
        }
        
        // run the test three times
        for (i = 0; i < 3; i++)
        {
            trial = i+1;
            [self.testNotice setText:[NSString stringWithFormat:@"Running trial #%u for %@", i+1,
                                      self.currTestName]];
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            startTime = [NSDate timeIntervalSinceReferenceDate];
            [self grabURL:sender];
        }
        });
    } else {
        // stop the test
        [sender setTitle:self.currTestName forState:UIControlStateNormal];
        running = false;
    }
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    [self.avg setText:[NSString stringWithFormat:@"%.3f Mbps", self.bandwidthTotal / 3.0]];

    // add info to Parse
    // call these commands in a concurrent thread to avoid disrupting the main (UI) thread
    dispatch_queue_t addToParse = dispatch_queue_create("adding to Parse", NULL);
    dispatch_sync(addToParse, ^{
        PFObject *trialObj = [PFObject objectWithClassName:@"wifiTest"];
        [trialObj setObject:self.currTestName forKey:@"test"];
        [trialObj setObject:self.trial1.text forKey:@"trial1"];
        [trialObj setObject:self.trial2.text forKey:@"trial2"];
        [trialObj setObject:self.trial3.text forKey:@"trial3"];
        [trialObj setObject:self.avg.text forKey:@"average"];
        [trialObj setObject:[NSString stringWithFormat:@"%f",self.lat]        forKey:@"latitude"];
        [trialObj setObject:[NSString stringWithFormat:@"%f",self.longitude]  forKey:@"longitude"];
        [trialObj setObject:[NSString stringWithFormat:@"%@",self.macAddress] forKey:@"MAC"];
        [trialObj save];
        self.trialObj = trialObj;
    });

    
    NSLog(@"the trailObj is %@", self.trialObj);
    NSLog(@"the object ID is poop: %@", self.trialObj.objectId);
   

    [self.testNotice setText:@"Tests Completed"];
    NSLog(@"/////////////Alllllllll Dooonnneeeee///////////");
    [self performSegueWithIdentifier:@"testResults" sender:self];
}


- (void)grabURL:(UIButton *)sender
{
    NSLog(@"Inside grabURL");

    NSURL *url;
    if ([sender.restorationIdentifier isEqualToString:@"largeFile"])
    {
        NSLog(@"Testing the big boy...");
        url = [NSURL URLWithString:@"http://weke.its.yale.edu/rails.box"];
    } else {
       NSLog(@"Testing the little guy");
        url = [NSURL URLWithString:@"http://weke.its.yale.edu/ios_test_file.dat"];
    }
   
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // there's a malloc error with the large file
    // since we're not writing to disk, we're putting too much info
    // into main memory
    endTime = [NSDate timeIntervalSinceReferenceDate];
    trialTime = endTime - startTime;
    NSLog(@"///////////the time was: %f///////////", trialTime);
    self.totalTime += trialTime;
    if ([self.currTestName isEqualToString:@"Test Small File"])
    {
        trialBandwidth = 8.0 * (5.0 / trialTime);
    } else {
        trialBandwidth = 8.0 * (772.0 / trialTime);
    }
    self.bandwidthTotal += trialBandwidth;
    
    switch(trial)
    {
        case 1:
            [self.trial1 setText:[NSString stringWithFormat:@"%.3f Mbps",trialBandwidth]];
            break;
        case 2:
            [self.trial2 setText:[NSString stringWithFormat:@"%.3f Mbps",trialBandwidth]];
            break;
        case 3:
            [self.trial3 setText:[NSString stringWithFormat:@"%.3f Mbps",trialBandwidth]];
            break;
    }
    NSLog(@"////////trial finished/////////\n\n");
    [self.currTest setTitle:self.currTestName forState:UIControlStateNormal];
    running = false;
    
    //performSelectorOnMainThread:withObject:waitUntilDone:
    
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Ruh roh...");
    //NSError *error = [request error];
}

// disgusting C code from StackOverflow
char*  getMacAddress(char* macAddress, char* ifName) {
    
    int  success;
    struct ifaddrs * addrs;
    struct ifaddrs * cursor;
    const struct sockaddr_dl * dlAddr;
    const unsigned char* base;
    int i;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != 0) {
            if ( (cursor->ifa_addr->sa_family == AF_LINK)
                && (((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == IFT_ETHER) && strcmp(ifName,  cursor->ifa_name)==0 ) {
                dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;
                base = (const unsigned char*) &dlAddr->sdl_data[dlAddr->sdl_nlen];
                strcpy(macAddress, "");
                for (i = 0; i < dlAddr->sdl_alen; i++) {
                    if (i != 0) {
                        strcat(macAddress, ":");
                    }
                    char partialAddr[3];
                    sprintf(partialAddr, "%02X", base[i]);
                    strcat(macAddress, partialAddr);
                    
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return macAddress;
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"testResults"]){
        TestResultsViewController *controller = (TestResultsViewController *)segue.destinationViewController;
        controller.lastObj = self.trialObj;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
