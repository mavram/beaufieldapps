//
//  UIWebViewExtensions.m
//  BeaufieldUtilitiesLib
//
//  Created by Mircea Avram on 11-03-02.
//  Copyright 2011 N/A. All rights reserved.
//

#import "UIWebViewExtensions.h"


@implementation UIWebView (__Extensions__)


- (NSString *)selectedText {
    return [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];
}


@end
