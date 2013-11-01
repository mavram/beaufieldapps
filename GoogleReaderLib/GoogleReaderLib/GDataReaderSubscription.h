//
//  GDataReaderSubscription.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataObject.h"

/*
<object>
    <string name="id">feed/http://www.deceptivemedia.co.uk/rss.asp</string>
    <string name="title">Deceptive Media » Photoblog</string>
    <list name="categories"/>
    <string name="sortid">4F719D8F</string>
    <number name="firstitemmsec">1274747530880</number>
</object>
*/

@interface GDataReaderSubscription : GDataObject {

    NSString *identifier;
    NSString *title;
    NSString *sortId;
    NSDate *firstItemTimestamp;
}

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* sortId;
@property (nonatomic, retain) NSDate* firstItemTimestamp;

- (id)initWithXMLElement:(NSXMLElement *)element;

- (BOOL) predefinedByGoogleReader;

@end
