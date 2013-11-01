//
//  PBSubscription.m
//  Photoblogs
//
//  Created by mircea on 10-07-21.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "GDataServiceGoogleReader.h"

#import "NSErrorExtensions.h"
#import "PBSubscription.h"
#import "PBModel.h"
#import "PBEntry.h"
#import "PBPhoto.h"
#import "PBSubscriptionHeuristics.h"


NSString *kNewPhotosSubscriptionTitle = @"New Photos";
NSString *kStarredPhotosSubscriptionTitle = @"Starred Photos";
NSString *kSubscriptionsEditorTitle = @"Subscriptions";


@implementation PBSubscription


@dynamic title;
@dynamic identifier;
@dynamic URL;
@dynamic isPhotoblog;
@dynamic isAtEnd;
@dynamic coverPhotoCacheURL;
@dynamic metaType;

+ (PBSubscription *)subscriptionWithGoogleReaderSubscription:(GDataReaderSubscription *)googleReaderSubscription {

	PBSubscription *s = (PBSubscription*)[NSEntityDescription insertNewObjectForEntityForName:@"Subscription"
                                                                       inManagedObjectContext:[[PBModel sharedModel] managedObjectContext]];
	[s setTitle:[googleReaderSubscription title]];
	[s setIdentifier:[googleReaderSubscription identifier]];
	[s setURL:[[GDataServiceGoogleReader allEntriesFeedURLForSubscription:[s identifier]] absoluteString]];
    [s setCoverPhotoCacheURL:nil];
    // mark subscriptions based on known heuristics
    [s setIsPhotoblog:[NSNumber numberWithBool:[s isKnownPhotoblog]]];
    [s setIsAtEnd:[NSNumber numberWithBool:NO]];
    [s setMetaType:[NSNumber numberWithInteger:PBMetaSubscriptionTypeRegular]];

	return s;
}


+ (PBSubscription *)subscriptionWithMetaType:(PBMetaSubscriptionType)metaType {
    
    
	PBSubscription *s = (PBSubscription*)[NSEntityDescription insertNewObjectForEntityForName:@"Subscription"
                                                                       inManagedObjectContext:[[PBModel sharedModel] managedObjectContext]];
    [s setMetaType:[NSNumber numberWithInteger:metaType]];
    if (metaType == PBMetaSubscriptionTypeNewPhotos) {    
        [s setTitle:kNewPhotosSubscriptionTitle];
        [s setIdentifier:kNewPhotosSubscriptionTitle];
        [s setURL:[[GDataServiceGoogleReader readingListEntriesFeedURL] absoluteString]];
        [s setIsAtEnd:[NSNumber numberWithBool:YES]];
    } else if (metaType == PBMetaSubscriptionTypeStarredPhotos) {    
        [s setTitle:kStarredPhotosSubscriptionTitle];
        [s setIdentifier:kStarredPhotosSubscriptionTitle];
        [s setURL:[[GDataServiceGoogleReader starredEntriesFeedURL] absoluteString]];
        [s setIsAtEnd:[NSNumber numberWithBool:NO]];
    } else if (metaType == PBMetaSubscriptionTypeSubscriptionsEditor) {
        [s setTitle:kSubscriptionsEditorTitle];
        [s setIdentifier:kSubscriptionsEditorTitle];
        [s setURL:kSubscriptionsEditorTitle];
        [s setIsAtEnd:[NSNumber numberWithBool:YES]];
    } else {
        [s setIsAtEnd:[NSNumber numberWithBool:NO]];
    }

    [s setCoverPhotoCacheURL:nil];
    [s setIsPhotoblog:[NSNumber numberWithBool:YES]];
    
	return s;
}


- (BOOL)isPhotoblogValue {
    
    return [[self isPhotoblog] boolValue];
}


- (BOOL)isAtEndValue {
    
    return [[self isAtEnd] boolValue];
}


- (PBMetaSubscriptionType)metaTypeValue {

    PBMetaSubscriptionType metaTypeValue = (PBMetaSubscriptionType)[[self metaType] integerValue];
    return metaTypeValue;
}


- (NSURL *)feedURL {
    
    return [NSURL URLWithString:[self URL]];
}


- (NSUInteger)numberOfUnreadEntries {
    
    if ([self metaTypeValue] == PBMetaSubscriptionTypeRegular) {
        return [PBEntry numberOfUnreadEntriesWithSubscription:self];
    } else if ([self metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        return [PBEntry numberOfUnreadEntries];
    }

    return 0;
}


- (NSArray *)unreadEntries {

    if ([self metaTypeValue] == PBMetaSubscriptionTypeRegular) {
        return [PBEntry unreadEntriesWithSubscription:self];
    } else if ([self metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        return [PBEntry unreadEntries];
    }
    
    return [[NSArray new] autorelease];
}


- (NSUInteger)numberOfEntries {
    return [[self entries] count];
}


- (NSArray *)entries {

    if ([self metaTypeValue] == PBMetaSubscriptionTypeRegular) {
        return [PBEntry entriesWithSubscription:self];
    } else if ([self metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        return [PBEntry unreadEntries];
    } else if ([self metaTypeValue] == PBMetaSubscriptionTypeStarredPhotos) {
        return [PBEntry starredEntries];
    }

    return [[NSArray new] autorelease];
}


- (void)deleteAllEntries {
    
    [self setIsAtEnd:[NSNumber numberWithBool:NO]];
    [[PBModel sharedModel] saveContext];
    
    NSArray *entries = [self entries];
    for (PBEntry *entry in entries) {
        [PBPhoto deleteAllPhotosWithEntry:[entry identifier]];
    }
    
    if ([self metaTypeValue] == PBMetaSubscriptionTypeStarredPhotos) {
        [PBEntry deleteAllStarredEntries];
    } else if ([self metaTypeValue] == PBMetaSubscriptionTypeRegular) {
        [PBEntry deleteAllEntriesWithSubscription:self];
    } else {
        // not supported
        NSAssert(NO, @"Not implemented");
    }
}


- (NSString *)coverPhotoCacheURLValue {
    
    // do we have custom cover
    if ([self coverPhotoCacheURL]) {
        return [self coverPhotoCacheURL];
    }
    
    // check to see if we have any photo from this subscription cached
    // if yes make it default cover
    NSArray *potentialCovers = [PBPhoto cachedPhotosWithSubscription:[self identifier]];
    if ([potentialCovers count]) {
        PBPhoto *photo = (PBPhoto *)[potentialCovers objectAtIndex:0];
        
        [self setCoverPhotoCacheURL:[photo cacheURL]];
        [[PBModel sharedModel] saveContext];
        
#ifdef __DEBUG_APP_LIFECYCLE__
        //BADebugMessage(@"Set <%@> as default cover for <%@>", [photo cacheURL], [self title]);
#endif
        return [self coverPhotoCacheURLValue];
    }
    
    // otherwise is the bundle
    NSString *coverName = @"Cover-Default";
    if ([self metaTypeValue] != PBMetaSubscriptionTypeRegular) {
        coverName = [NSString stringWithFormat:@"Cover-%@", [self title]];
    }
    
    return [[[NSBundle mainBundle] URLForResource:coverName withExtension:@"png"] path];
}


@end
