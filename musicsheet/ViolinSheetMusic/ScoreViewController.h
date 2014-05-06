//
//  ScoreViewController.h
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "ReaderViewController.h"
#import "DownloadManager.h"
#import "CircularProgressView.h"

@interface ScoreViewController : UITableViewController <ReaderViewControllerDelegate, DownloadManagerDelegate>

@property (nonatomic) NSString *composer;

@end
