//
//  GDataReaderUnreadCount.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataReaderUnreadCount.h"


@implementation GDataReaderUnreadCount


@synthesize identifier;
@synthesize count;
@synthesize newestItemTimestamp;


- (id)initWithXMLElement:(NSXMLElement *)element {

    NSArray *stringElements = [element elementsForName:@"string"];
    {
        NSXMLElement *stringElement;
        for (stringElement in stringElements) {
            NSString* elementName = [[stringElement attributeForName:@"name"] stringValue];
            
            if ([elementName isEqualToString:@"id"]) {
                [self setIdentifier:[stringElement stringValue]];
            } else {
                // do nothing
            }
        }        
    }
    
    NSArray *numberElements = [element elementsForName:@"number"];
    {
        NSXMLElement *numberElement;
        for (numberElement in numberElements) {
            NSString* elementName = [[numberElement attributeForName:@"name"] stringValue];
            
            if ([elementName isEqualToString:@"count"]) {
                NSString *elementValue = [numberElement stringValue];
                [self setCount:[NSNumber numberWithInt:[elementValue intValue]]];
            } else {
                if ([elementName isEqualToString:@"newestItemTimestampUsec"]) {
                    NSString *elementValue = [numberElement stringValue];
                    NSDate *elementValueAsDate = [[[NSDate alloc] initWithTimeIntervalSince1970:([elementValue doubleValue])] autorelease];
                    [self setNewestItemTimestamp:elementValueAsDate];
                } else {
                    // do nothing
                }
            }
        }        
    }
    
    return self;
}

-(BOOL) isTotalCount {

    NSRange range = [identifier rangeOfString:@"reading-list"];
    
    if (range.location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (void) dealloc {
    
    [self setIdentifier:nil];
    [self setCount:nil];
    [self setNewestItemTimestamp:nil];
    
    [super dealloc];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@> <%@> <%@>", identifier, count, newestItemTimestamp];
}    


@end
