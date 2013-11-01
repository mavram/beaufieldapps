//
//  GDataReaderEntrySource.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataBaseElements.h"
#import "GDataReaderEntrySource.h"

@interface GDataReaderStreamIdAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataReaderStreamIdAttribute
+ (NSString *)extensionElementURI       { return @"http://www.google.com/schemas/reader/atom/"; }
+ (NSString *)extensionElementPrefix    { return @"gr"; }
+ (NSString *)extensionElementLocalName { return @"stream-id"; }
@end

@implementation GDataReaderEntrySource

+ (NSString *)extensionElementURI       { return nil; }
+ (NSString *)extensionElementPrefix    { return nil; }
+ (NSString *)extensionElementLocalName { return @"source"; }

- (void)addParseDeclarations {
    [super addParseDeclarations];
}

- (void)addExtensionDeclarations {
    
    [super addExtensionDeclarations];
    
    Class entryClass = [self class];
    [self addExtensionDeclarationForParentClass:entryClass
                                   childClasses: [GDataAtomID class], [GDataAtomTitle class], [GDataLink class], nil];
    
    // Attributes
    [self addAttributeExtensionDeclarationForParentClass:[self class]
                                              childClass:[GDataReaderStreamIdAttribute class]];
}

- (NSString *)identifier {
    GDataAtomID *obj = [self objectForExtensionClass:[GDataAtomID class]];
    return [obj stringValue];
}

- (void)setIdentifier:(NSString *)str {
    GDataAtomID *obj = [GDataAtomID valueWithString:str];
    [self setObject:obj forExtensionClass:[GDataAtomID class]];
}

- (GDataTextConstruct *)title {
    GDataAtomTitle *obj = [self objectForExtensionClass:[GDataAtomTitle class]];
    return obj;
}

- (void)setTitle:(GDataTextConstruct *)obj {
    [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitleWithString:(NSString *)str {
    GDataAtomTitle *obj = [GDataAtomTitle textConstructWithString:str];
    [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (NSArray *)links {
    NSArray *array = [self objectsForExtensionClass:[GDataLink class]];
    return array;
}

- (void)setLinks:(NSArray *)array {
    [self setObjects:array forExtensionClass:[GDataLink class]];
}

- (void)addLink:(GDataLink *)obj {
    [self addObject:obj forExtensionClass:[GDataLink class]];
}

- (GDataLink *)alternateLink {

    return [GDataLink linkWithRel:@"alternate"
                             type:nil
                        fromLinks:[self links]];
}

- (NSString *)streamId {
    
    NSString *attrValue = [self attributeValueForExtensionClass:[GDataReaderStreamIdAttribute class]];
    return attrValue;
}


@end
