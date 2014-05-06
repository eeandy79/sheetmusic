//
//  ScoreViewCell.m
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ScoreViewCell.h"

@implementation ScoreViewCell

@synthesize title;
@synthesize progress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
