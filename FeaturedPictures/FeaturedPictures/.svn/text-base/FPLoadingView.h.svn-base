//
//  FPLoadingView.h
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FPLoadingDelegate <NSObject>

- (BOOL)isLoaded;
- (BOOL)isLoading;
- (BOOL)isOffline;

@end


@interface FPLoadingView : UIView {

}

@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *messageLabel; 
@property (nonatomic, retain) NSString *name; 
@property (nonatomic, assign) id<FPLoadingDelegate> loadingDelegate;


@end
