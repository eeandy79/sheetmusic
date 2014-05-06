//
//  ScoreViewCell.h
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end
