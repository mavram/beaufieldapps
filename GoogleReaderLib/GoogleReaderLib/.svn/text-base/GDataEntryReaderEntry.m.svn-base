//
//  GDataEntryReaderEntry.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "NSStringExtensions.h"
#import "NSErrorExtensions.h"
#import "GDataEntryReaderEntry.h"


@implementation GDataEntryReaderEntry

@synthesize hasStar;
@synthesize isRead;
@synthesize isKeptUnread;
@synthesize isFresh;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {

    self = [super initWithXMLElement:element
                              parent:parent];
    
#ifdef __DEBUG_RSS__
    BADebugMessage(@"%@", element);
#endif

    // cache ivars
    hasStar = NO;
    isRead = NO;
    isKeptUnread = NO;
    isFresh = NO;

    NSArray *categories = [self categories];
    GDataCategory *category;
    for (category in categories) {
        NSString *categoryLabel = [category label];
        if ([categoryLabel isEqualToString:@"starred"]) {
            hasStar = YES;
        } else if ([categoryLabel isEqualToString:@"read"]) {
            isRead = YES;
        } else if ([categoryLabel isEqualToString:@"kept-unread"]) {
            isKeptUnread = YES;
        } else if ([categoryLabel isEqualToString:@"fresh"]) {
            isFresh = YES;
        }
    }

    return self;
}

- (void)addExtensionDeclarations {

    [super addExtensionDeclarations];
    [self addExtensionDeclarationForParentClass:[self class] childClass:[GDataReaderEntrySource class]];
}

- (void)dealloc {

    [super dealloc];
}


- (GDataReaderEntrySource *)source {
    GDataReaderEntrySource *obj = [self objectForExtensionClass:[GDataReaderEntrySource class]];
    return obj;
}


- (BOOL)isEqual:(GDataEntryReaderEntry *)other {
    
    if (self == other) return YES;
    if (![other isKindOfClass:[GDataEntryReaderEntry class]]) return NO;
    
    return AreEqualOrBothNil([self title], [other title]) && AreEqualOrBothNil([self identifier], [other identifier]);
}

- (NSUInteger)hash {
    return 1000000*[[self title] hash] + 1000*[[self identifier] hash];
}

- (NSString*)description {
    NSString *description = [NSString stringWithFormat:@"<%@> <%@> <%@>",
                             [[self title] stringValue], [self identifier], [[[self source] title] stringValue]];
    return description;
}

- (void)dumpIVars {
    
    BADebugMessage(@"identifier<%@>",  [self identifier]);
    BADebugMessage(@"feedIdentifier<%@>",  [[self source] streamId]);
    BADebugMessage(@"feedTitle<%@>",  [[[self source] title] stringValue]);
    BADebugMessage(@"title<%@> type<%@>", [[self title] stringValue], [[self title] type]);
    if ([self summary]) {
        BADebugMessage(@"summary<%@> type<%@>", [[self summary] stringValue], [[self summary] type]);
    }
    if ([self content]) {
        BADebugMessage(@"content<%@> type<%@>", [[self content] stringValue], [[self content] type]);
    }

    for (GDataCategory *category in [self categories]) {
        if (category) {
            BADebugMessage(@"label<%@>", [category label]);
        }
    }

    if ([self feedLink]) {
        BADebugMessage(@"feedLink: rel<%@> title<%@> href<%@> type<%@>",
                       [[self feedLink] rel], [[self feedLink] title], [[self feedLink] href], [[self feedLink] type]);
    }
    if ([self alternateLink]) {
        BADebugMessage(@"alternateLink: rel<%@> title<%@> href<%@> type<%@>",
                       [[self alternateLink] rel], [[self alternateLink] title], [[self alternateLink] href], [[self alternateLink] type]);
    }
    if ([self relatedLink]) {
        BADebugMessage(@"relatedLink: rel<%@> title<%@> href<%@> type<%@>",
                       [[self relatedLink] rel], [[self relatedLink] title], [[self relatedLink] href], [[self relatedLink] type]);
    }
    if ([self postLink]) {
        BADebugMessage(@"postLink: rel<%@> title<%@> href<%@> type<%@>",
                       [[self postLink] rel], [[self postLink] title], [[self postLink] href], [[self postLink] type]);
    }
    if ([self HTMLLink]) {
        BADebugMessage(@"HTMLLink: rel<%@> title<%@> href<%@> type<%@>",
                       [[self HTMLLink] rel], [[self HTMLLink] title], [[self HTMLLink] href], [[self HTMLLink] type]);
    }

#ifdef __DEBUG_RSS__
    BADebugMessage(@"publishedDate<%@>",  [[self publishedDate] stringValue]);
    BADebugMessage(@"updatedDate<%@>",  [[self updatedDate] stringValue]);
    BADebugMessage(@"editedDate<%@>",  [[self editedDate] stringValue]);
    BADebugMessage(@"kind<%@>",  [self kind]);
    BADebugMessage(@"resourceID<%@>",  [self resourceID]);    
    BADebugMessage(@"rightsString<%@> type<%@>", [[self rightsString] stringValue], [[self rightsString] type]);
    
    for (GDataLink *link in [self links]) {
        BADebugMessage(@"rel<%@> title<%@> href<%@> type<%@>",
                       [link rel], [link title], [link href], [link type]);
    }
    
    for (GDataPerson *person in [self authors]) {
        BADebugMessage(@"author<%@>", [person name]);
    }
    for (GDataPerson *person in [self contributors]) {
        BADebugMessage(@"contributor<%@>", [person name]);
    }
#endif
}


@end
