//
//  GDataFeedReader.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataFeedReader.h"
#import "GDataEntryReaderEntry.h"


@implementation GDataAtomReaderContinuation
+ (NSString *)extensionElementURI       { return @"http://www.google.com/schemas/reader/atom/"; }
+ (NSString *)extensionElementPrefix    { return @"gr"; }
+ (NSString *)extensionElementLocalName { return @"continuation"; }
@end


@implementation GDataFeedReader

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {

    [super initWithXMLElement:element parent:parent];
    
    return self;
}

- (Class)classForEntries {
    return [GDataEntryReaderEntry class];
}

- (void)addExtensionDeclarations {
    
    [super addExtensionDeclarations];
    
    [self addExtensionDeclarationForParentClass:[self class]
                                     childClass:[GDataAtomReaderContinuation class]];
}

- (GDataTextConstruct *)continuation {
    GDataAtomReaderContinuation *obj = [self objectForExtensionClass:[GDataAtomReaderContinuation class]];
    return obj;
}

- (void)setContinuation:(GDataTextConstruct *)obj {
    [self setObject:obj forExtensionClass:[GDataAtomReaderContinuation class]];
}

- (void)setContinuationWithString:(NSString *)str {
    GDataAtomReaderContinuation *obj = [GDataAtomReaderContinuation textConstructWithString:str];
    [self setObject:obj forExtensionClass:[GDataAtomReaderContinuation class]];
}


@end
