//
//  GDataFeedReader.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataFeedBase.h"


/*
 <gr:continuation>CODViumm66IC</gr:continuation>
 */
@interface GDataAtomReaderContinuation : GDataTextConstruct <GDataExtension>
@end


@interface GDataFeedReader : GDataFeedBase {
    
}


- (GDataTextConstruct *)continuation;
- (void)setContinuation:(GDataTextConstruct *)obj;
- (void)setContinuationWithString:(NSString *)str;


@end

