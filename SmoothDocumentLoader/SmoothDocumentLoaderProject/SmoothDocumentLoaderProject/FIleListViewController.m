//
//  FIleListViewController.m
//  SmoothDocumentLoaderProject
//
//  Created by Ravi Dixit on 16/02/12.
//  Copyright (c) 2012 QUAGNITIA. All rights reserved.
//

#import "FIleListViewController.h"

@implementation FIleListViewController
@synthesize FileListTableView;
@synthesize fileURL;

#define kStringURLViewControllerPDF @"https://developer.apple.com/library/ios/DOCUMENTATION/UIKit/Reference/UIViewController_Class/UIViewController_Class.pdf"

#define kStringURLQLPreviewControllerPDF @"https://developer.apple.com/library/ios/DOCUMENTATION/NetworkingInternet/Reference/QLPreviewController_Class/QLPreviewController_Class.pdf"

#define kStringURLUIDocumentInteractionControllerPDF @"https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDocumentInteractionController_class/UIDocumentInteractionController_class.pdf"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    fileNameList = [[NSArray alloc]initWithObjects:@"UIViewController",@"QLPreview class",@"UIDocumentInteractionController", nil];
    // Do any additional setup after loading the view from its nib.
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
    return [fileNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [fileNameList objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //initializing the fileURL object with the URL links to be loaded
    switch (indexPath.row) {
        case 0: 
            fileURL = [NSURL URLWithString:kStringURLViewControllerPDF];
            break;

      case 1:
            fileURL = [NSURL URLWithString:kStringURLQLPreviewControllerPDF];
            break;
            case 2:
            fileURL = [NSURL URLWithString:kStringURLUIDocumentInteractionControllerPDF];
            break;
    }
    //creating the object of the QLPreviewController
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    
    //settnig the datasource property to self
    previewController.dataSource = self;
    
    //pusing the QLPreviewController to the navigation stack
    [[self navigationController] pushViewController:previewController animated:YES];
    //remove the right bar print button
    [previewController.navigationItem setRightBarButtonItem:nil];
    [previewController release];
}

#pragma mark -
#pragma mark QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 30; //you can increase the this
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return fileURL;
}

- (void)viewDidUnload
{
    [FileListTableView release];
    FileListTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [FileListTableView release];
    [fileNameList release];
    [super dealloc];
}
@end
