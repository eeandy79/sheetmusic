//
//  ScoreViewController.m
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ScoreViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ReaderViewController.h"
#import "ScoreViewCell.h"

@interface SongRecord : NSObject
@property  NSString *url;
@property  NSString *name;
@property  NSString *guid;
@end

@implementation SongRecord
@synthesize url;
@synthesize name;
@synthesize guid;

-(SongRecord*) initWithurl:(NSString *) _url andname:(NSString *) _name andguid:(NSString *) _guid 
{
    self = [super init];
    if ( self != nil ) {
        self.url  = _url;
        self.name = _name;
        self.guid = _guid;
    }
    return self;
}  
@end

@interface ScoreViewController ()
@property (nonatomic, strong) NSMutableArray *song_records;
@property (nonatomic, strong) NSIndexPath *active_index;
@property (nonatomic, strong) DownloadManager *dm;
@property (nonatomic, strong) NSFileManager *fm;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) CircularProgressView *progressView;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation ScoreViewController 

@synthesize composer;
@synthesize active_index;
@synthesize dm;
@synthesize fm;
@synthesize song_records;
@synthesize db;
@synthesize progressView;
@synthesize cancelButton;

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"error opening database");
    }

    FMResultSet *rs = [db executeQuery:@"select * from music2 where composer = ?", self.composer];
    song_records= [NSMutableArray array];
    while ([rs next]) {
        SongRecord *record = [[SongRecord alloc] initWithurl:[rs stringForColumn:@"pdf_url"]
                                                     andname:[rs stringForColumn:@"song_title"]
                                                     andguid:[rs stringForColumn:@"guid"]];
        [song_records addObject:record];
    }
    [db close];
    
    dm = [[DownloadManager alloc] initWithDelegate:self]; 
    fm = [NSFileManager new];
    
    // Add progress bar settings
    UIColor *backColor = [UIColor colorWithRed:236.0/255.0
                                         green:236.0/255.0
                                          blue:236.0/255.0
                                         alpha:1.0];
    UIColor *progressColor = [UIColor colorWithRed:82.0/255.0
                                             green:135.0/255.0
                                              blue:237.0/255.0
                                             alpha:1.0];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    cancelButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame= CGRectMake(200, 15, 100, 100);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //alloc CircularProgressView instance
    self.progressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)
                                                          backColor:backColor
                                                      progressColor:progressColor
                                                          lineWidth:30];
    
    //add CircularProgressView
    [self.progressView setHidden:YES];
    [self.cancelButton setHidden:YES];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.cancelButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [song_records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreViewCell* cell = (ScoreViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreViewCell"];
    SongRecord *record = [self.song_records objectAtIndex:indexPath.row];
    [cell.title setText:record.name];
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (NSString*)getFilePath:(NSIndexPath *)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    SongRecord *record = [self.song_records objectAtIndex:active_index.row];
    NSString *fileName = [record.url lastPathComponent];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, @"Download", fileName];
    return filePath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    active_index = indexPath;
    [self.progressView updateProgressCircle:0.0];
    [self.progressView setHidden:NO];
    [self.cancelButton setHidden:NO];
    
    NSString *filePath = [self getFilePath:active_index];
    SongRecord *record = [self.song_records objectAtIndex:active_index.row];
    NSString *guid = record.guid;
    
    if (![db open]) {
        NSLog(@"error opening database");
    }
    
    NSUInteger count = [db intForQuery:@"select count(*) from archive where guid = ?", guid];
    [db close];
    
    if (count) { //todo need to check if really have file there, otherwise need to download
        [self performSegueWithIdentifier:@"ScoreSegue" sender:self];
    }
    else {
        NSURL *target_url = [NSURL URLWithString:record.url];
        [dm addDownloadWithFilename:filePath URL:target_url];
        [dm start];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ScoreSegue"]) 
    {
        NSString *filePath = [self getFilePath:active_index];
            
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        document.pageNumber = [NSNumber numberWithInteger:1];
            
        ReaderViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        assert([vc initWithReaderDocument:document] != nil); // todo: using NSError
    }
}

#pragma mark - ReaderViewControllerDelegrate
- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    ReaderDocument *docObject = [viewController getActiveDocument];
    if ([docObject.isArchived boolValue] == TRUE) 
    {
        if (![db open]) {
            NSLog(@"error opening database");
        }
        
        SongRecord *record = [self.song_records objectAtIndex:active_index.row];
        NSString *guid = record.guid;
        NSString *filePath = [self getFilePath:active_index];
    
        [db beginTransaction];
        BOOL rv = [db executeUpdate:@"insert into archive(guid, filePath) values(?,?)", guid, filePath, nil];
        if (!rv) {
            NSLog(@"cannot insert record to db");
        }
        [db commit];
        [db close];
    }
    else {
        if (![db open]) {
            NSLog(@"error opening database");
        }
        
        SongRecord *record = [self.song_records objectAtIndex:active_index.row];
        NSString *guid = record.guid;
        
        NSString *filePath = [self getFilePath:active_index];
        [db beginTransaction];
        [db executeUpdate:@"delete from archive where guid = ?", guid];
        [db commit];
        [db close];
        
        [fm removeItemAtPath:filePath error:nil];
    }
    
    // todo: we can handle the save operation here
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DownloadManagerDelegate
- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download
{
    [self.progressView updateProgressCircle:0.0];
    [self.progressView setHidden:YES];
    [self.cancelButton setHidden:YES];
    [self performSegueWithIdentifier:@"ScoreSegue" sender:self];
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download
{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.alpha = 0;
        self.cancelButton.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished)
        {
            [self.progressView setHidden:YES];
            [self.cancelButton setHidden:YES];
            self.progressView.alpha = 1;
            self.cancelButton.alpha = 1;
            [self.progressView updateProgressCircle:0.0];
        }
    }];
    
    if (download.error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                        message:@"Unable to down the file, please check your connection and retry."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download
{
    if (download.expectedContentLength != 0) {
        float p = (float)download.progressContentLength / (float)download.expectedContentLength;
        [self.progressView updateProgressCircle:p];
    }
}

#pragma mark - CancelButtonAction
- (void)cancelButtonAction
{
    [self.dm cancelAll];
}

@end // end implementation
