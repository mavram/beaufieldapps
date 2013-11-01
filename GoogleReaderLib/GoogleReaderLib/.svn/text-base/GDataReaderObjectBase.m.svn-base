//
//  GDataReaderObjectBase.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataReaderObjectBase.h"


@implementation GDataReaderObjectBase


@synthesize objects;


- (id)initWithData:(NSData *)data {
    
    // entry point for creation of feeds from file or network data
    NSError *error = nil;
    NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithData:data
                                                              options:0
                                                                error:&error] autorelease];
    if (xmlDocument) {
        NSXMLElement* root = [xmlDocument rootElement];
        return [self initWithXMLElement:root parent:nil];
    } else {
        // could not parse XML into a document
        [self release];
        return nil;
    }
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
    
    // entry point for creation of lists inside elements
    self = [super initWithXMLElement:element
                              parent:nil];
        
//    BADebugMessage(@"element<%@>", element);

    // start with empty array
    objects = [[NSMutableArray alloc] init];
    
    // create list element 
    NSXMLElement *listElement = [self childWithQualifiedName:@"list" namespaceURI:@"*" fromElement:(NSXMLElement *)element];
    if (listElement == nil) {
        return self;
    }
    
    // parse each object     
    NSArray *objectElements = [listElement elementsForName:@"object"];
    {
        NSXMLElement *objectElement;
        for (objectElement in objectElements) {
            id object = [self readerObjectWithXMLElement:objectElement];
            if (object != nil) {
//                BADebugMessage(@"readerObject <%@>", object);
                [objects addObject: object];
            }
        }        
    }
    
    return self;
}

- (id)readerObjectWithXMLElement:(NSXMLElement *)objectElement {
    return nil;
}

- (NSXMLElement *)XMLElement {

    NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"object"];

    return element;    
}


#pragma mark -
#pragma mark NSObject's Overrides


- (void)dealloc {

    [objects release];

    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone 
{
    GDataReaderObjectBase* newObject = [super copyWithZone:zone];
    [newObject setObjects: [self objects]];
    return newObject;
}

- (BOOL)isEqual:(GDataReaderObjectBase *)other {
    
    if (self == other) return YES;
    if (![other isKindOfClass:[GDataReaderObjectBase class]]) return NO;
    
    return [super isEqual:other] && AreEqualOrBothNil([self objects], [other objects]);
}


@end
