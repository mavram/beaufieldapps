//
//  GDataReaderObjectSubscriptionsList.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataReaderObjectSubscriptionsList.h"
#import "GDataReaderSubscription.h"


@implementation GDataReaderObjectSubscriptionsList


- (id)readerObjectWithXMLElement:(NSXMLElement *)objectElement {
    // create subscriptions
    return [[[GDataReaderSubscription alloc ] initWithXMLElement:objectElement] autorelease];
}


@end
