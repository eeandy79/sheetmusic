//
//  WebViewController.h
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Score.h"

@class WebViewController;

@protocol WebViewControllerDelegate <NSObject>

- (void)webViewControllerDidBack:(WebViewController*)controller;

@end

@interface WebViewController : ViewController

@property (strong, nonatomic) IBOutlet Score *viewWeb;

@property (nonatomic) NSString *fullUrl;

@property (nonatomic, weak) id <WebViewControllerDelegate> delegate;

- (IBAction)back:(id)sender;

@end
