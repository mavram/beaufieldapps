//
//  GDataReaderEntrySource.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataEntryBase.h"


/*

 Entry source like:
 
 <source gr:stream-id="feed/http://designyoutrust.com/feed/">
    <id>tag:google.com,2005:reader/feed/http://designyoutrust.com/feed/</id>
    <title type="html">Design You Trust</title>
    <link rel="alternate" href="http://designyoutrust.com" type="text/html"/>
 </source>

*/


@interface GDataReaderEntrySource : GDataObject <GDataExtension> {
    
}

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)theIdString;

- (GDataTextConstruct *)title;
- (void)setTitle:(GDataTextConstruct *)theTitle;
- (void)setTitleWithString:(NSString *)str;

- (NSArray *)links;
- (void)setLinks:(NSArray *)links;
- (void)addLink:(GDataLink *)link;

- (GDataLink *)alternateLink;

- (NSString *)streamId;


@end
