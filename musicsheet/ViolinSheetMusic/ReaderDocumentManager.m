//
//  ReaderDocumentManager.m
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/2f1/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ReaderDocumentManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface ReaderDocumentManager ()
@property (nonatomic, strong) FMDatabase *db;
@end

@implementation ReaderDocumentManager

@synthesize db;

+ (id)sharedManager {
    static ReaderDocumentManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"mydatabase.sqlite"];
        
        db = [FMDatabase databaseWithPath:dbPath];
        
    }
    return self;
}

- (ReaderDocument*) getDocument:(NSString *)guid
{   
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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
