//
//  AppDelegate.m
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ComposerViewController.h"
#import "FMDatabase.h"

@implementation AppDelegate {
    NSMutableArray *composers;
}

@synthesize window = _window;

- (void)createCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    NSString *appDBPath = [documentsDirectory stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    success = [fm fileExistsAtPath:appDBPath];
    if (success) {
        return;
    }
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mydatabase.sqlite"];
    success = [fm copyItemAtPath:defaultDBPath toPath:appDBPath error:&error];

    if (!success) {
        NSAssert1(0, @"Failed to create writable database with message '%@'.", [error localizedDescription]);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createCopyOfDatabaseIfNeeded];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    BOOL rv = [database open];
    if (!rv) {
        NSLog(@"error opening database");
    }
    
    NSString *sqlSelectQuery = @"SELECT DISTINCT composer from music";
    FMResultSet *rs = [database executeQuery:sqlSelectQuery];
    
    composers = [NSMutableArray array];
    while ([rs next]) {
        NSString *composer_name = [rs stringForColumn:@"composer"];
        [composers addObject:composer_name];
        NSLog(@"%@", composer_name);
    }
    
    [database close];
    
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    
    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
    
    ComposerViewController *composerViewController = [[navigationController viewControllers] objectAtIndex:0];
    
    composerViewController.composers = composers;
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
