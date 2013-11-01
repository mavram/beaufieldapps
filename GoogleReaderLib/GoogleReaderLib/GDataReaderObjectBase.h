//
//  GDataReaderObjectBase.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataObject.h"

/*
 <object>
    <list name="...">
        ...
    <list>
 </object>
 */
@interface GDataReaderObjectBase : GDataObject {
    NSMutableArray *objects;
}

@property (nonatomic, retain) NSMutableArray* objects;

- (id)initWithData:(NSData *)data;
- (id)readerObjectWithXMLElement:(NSXMLElement *)objectElement;


@end
