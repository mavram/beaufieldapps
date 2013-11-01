//
//  GDataServiceBaseExtensions.m
//  GoogleReaderLib
//
//  Created by mircea on 10-08-10.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "GDataServiceBaseExtensions.h"

static NSString* const kFetcherDelegateKey          = @"_delegate";
static NSString* const kFetcherFinishedSelectorKey  = @"_finishedSelector";

@implementation GDataServiceBase(__DataFetcherExtensions__)

+ (void)invokeCallback:(SEL)callbackSel
                target:(id)target
                object:(id)object
                 error:(id)error {
    
    NSMethodSignature *signature = [target methodSignatureForSelector:callbackSel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:callbackSel];
    [invocation setTarget:target];
    [invocation setArgument:&object atIndex:2];
    [invocation setArgument:&error atIndex:3];
    [invocation invoke];
}

- (void)fetchDataWithURL:(NSURL *)dataURL
              dataToPost:(NSData*)dataToPost
                delegate:(id)delegate
       didFinishSelector:(SEL)finishedSelector {

    NSString *httpMethod = nil;
    if (dataToPost != nil) {
        httpMethod = @"POST";
    }
    
    NSMutableURLRequest *request = [self requestForURL:dataURL
                                                  ETag:nil
                                            httpMethod:httpMethod];
    GTMHTTPFetcher* dataFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [dataFetcher setPostData:dataToPost];
    [dataFetcher setProperty:delegate forKey:kFetcherDelegateKey];
    [dataFetcher setProperty:NSStringFromSelector(finishedSelector)
                      forKey:kFetcherFinishedSelectorKey];
    [dataFetcher setRetryEnabled:YES];
    
    [dataFetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(dataFetcher:finishedWithData:error:)];   
}


- (void)dataFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {

    id delegate = [fetcher propertyForKey:kFetcherDelegateKey];
    SEL finishedSelector = NSSelectorFromString([fetcher propertyForKey:kFetcherFinishedSelectorKey]);
    if (finishedSelector) {
        [[self class] invokeCallback:finishedSelector
                              target:delegate
                              object:data
                               error:error];
    }
    
}


@end

