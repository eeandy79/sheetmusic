//
//  FIleListViewController.h
//  SmoothDocumentLoaderProject
//
//  Created by Ravi Dixit on 16/02/12.
//  Copyright (c) 2012 QUAGNITIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface FIleListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDataSource,
QLPreviewControllerDelegate>
{
    IBOutlet UITableView *FileListTableView;
    NSArray *fileNameList;
    NSURL *fileURL;
}
@property(nonatomic,retain) NSURL *fileURL;
@property (nonatomic,retain) UITableView *FileListTableView;

@end
