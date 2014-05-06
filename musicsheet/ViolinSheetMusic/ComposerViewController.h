//
//  PlayersViewControllerViewController.h
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/20/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposerViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *composers;

@property (nonatomic, strong) NSString *target_composers;

@property (strong, nonatomic) IBOutlet UISearchBar *composerSearchBar;

@property (nonatomic, strong) NSMutableArray *filtered_composers;

@end
