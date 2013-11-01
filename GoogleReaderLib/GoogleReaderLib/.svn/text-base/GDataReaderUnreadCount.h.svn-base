//
//  GDataReaderUnreadCount.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataObject.h"

/*
 <object>
     <string name="id">feed/http://www.pwop.com/feed.aspx?show=dotnetrocks</string>
     <number name="count">3</number>
     <number name="newestItemTimestampUsec">1255568508813466</number>
 </object>
*/

@interface GDataReaderUnreadCount : GDataObject {

    NSString *identifier;
    NSNumber *count;
    NSDate *newestItemTimestamp;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSNumber* count;
@property (nonatomic, retain) NSDate* newestItemTimestamp;

- (id)initWithXMLElement:(NSXMLElement *)element;
- (BOOL)isTotalCount;

@end
