//
//  GDataEntryReaderEntry.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataEntryBase.h"
#import "GDataReaderEntrySource.h"


@interface GDataEntryReaderEntry : GDataEntryBase {

}

@property (nonatomic) BOOL hasStar;
@property (nonatomic) BOOL isRead;
@property (nonatomic) BOOL isKeptUnread;
@property (nonatomic) BOOL isFresh;

- (GDataReaderEntrySource *)source;

- (void)dumpIVars;

@end
