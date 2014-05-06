//
//  WebViewController.m
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize viewWeb;
@synthesize fullUrl;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [viewWeb loadRequest:requestObj];
}

- (void)viewDidUnload
{
    [self setViewWeb:nil];
    [self setViewWeb:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender
{
    [self.delegate webViewControllerDidBack:self];
}

@end
