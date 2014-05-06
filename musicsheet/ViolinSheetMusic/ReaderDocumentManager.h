//
//  ReaderDocumentManager.h
//  ViolinSheetMusic
//
//  Created by Andy Chang on 9/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ReaderDocument.h"

@interface ReaderDocumentManager : NSObject {
}

+ (id)sharedManager;

- (ReaderDocument*) getDocument:(NSString *)guid;

@end
