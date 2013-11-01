//
//  FPFetchHTTPDataOperation.h
//  FeaturedPictures
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMHTTPFetcher.h"


extern NSString *kDidDetectNetworkFailureNotification;


@interface FPFetchHTTPDataOperation : NSOperation {

@private
    GTMHTTPFetcher *_httpFetcher;
	BOOL _isFetching;
}


- (id)initWithURL:(NSURL *)url;


@end



