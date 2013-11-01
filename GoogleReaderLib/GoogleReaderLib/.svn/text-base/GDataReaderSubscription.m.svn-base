//
//  GDataReaderSubscription.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataReaderSubscription.h"


@implementation GDataReaderSubscription


@synthesize identifier;
@synthesize title;
@synthesize sortId;
@synthesize firstItemTimestamp;


- (id)initWithXMLElement:(NSXMLElement *)element {

    NSArray *stringElements = [element elementsForName:@"string"];
    {
        NSXMLElement *stringElement;
        for (stringElement in stringElements) {
            NSString* elementName = [[stringElement attributeForName:@"name"] stringValue];
            
            if ([elementName isEqualToString:@"id"]) {
                [self setIdentifier:[stringElement stringValue]];
            } else {
                if ([elementName isEqualToString:@"title"]) {
                    [self setTitle:[stringElement stringValue]];
                } else {
                    if ([elementName isEqualToString:@"sortid"]) {
                        [self setSortId:[stringElement stringValue]];
                    } else {
                        // do nothing
                    }                
                }            
            }
        }        
    }

    NSArray *numberElements = [element elementsForName:@"number"];
    {
        NSXMLElement *numberElement;
        for (numberElement in numberElements) {
            NSString* elementName = [[numberElement attributeForName:@"name"] stringValue];
            
            if ([elementName isEqualToString:@"firstitemmsec"]) {
                NSString *elementValue = [numberElement stringValue];
                NSDate *elementValueAsDate = [[[NSDate alloc] initWithTimeIntervalSince1970:([elementValue doubleValue]/1000)] autorelease];
                [self setFirstItemTimestamp:elementValueAsDate];
            } else {
                // do nothing
            }
        }        
    }

    return self;
}

- (BOOL)predefinedByGoogleReader {
    
    if ([[self title] rangeOfString:@"reading-list"].location != NSNotFound) {
        return YES;
    }

    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    GDataReaderSubscription* newObject = [super copyWithZone:zone];
    [newObject setTitle: [self title]];
    return newObject;
}

- (BOOL)isEqual:(GDataReaderSubscription *)other {
    
    if (self == other) return YES;
    if (![other isKindOfClass:[GDataReaderSubscription class]]) return NO;
    
    return [super isEqual:other] && AreEqualOrBothNil([self title], [other title]);
}

- (void)dealloc {

    [self setIdentifier:nil];
    [self setTitle:nil];
    [self setSortId:nil];
    [self setFirstItemTimestamp:nil];

    [super dealloc];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@> <%@> <%@> <%@>", identifier, title, sortId, firstItemTimestamp];
}


@end
