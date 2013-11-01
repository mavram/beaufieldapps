//
//  PBGridView.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBGridViewThumb.h"


@protocol PBGridViewDelegate <NSObject>

- (NSUInteger)numberOfThumbs;
- (PBGridViewThumb *)thumbAtIndex:(NSUInteger)idx;
- (void)didSelectThumbAtIndex:(NSUInteger)idx;
- (BOOL)hasMoreThumbs;

@optional
- (void)fetchThumbs;

@end


@interface PBGridView : UIView<UIScrollViewDelegate> {
    
    BOOL _needsThumbsLayout;
    NSUInteger _currentNumberOfColumns;
    NSUInteger _pageNo;
    BOOL _isLoadingNextPage;
    BOOL _needsToLoadNextPage;
    BOOL _isLoadingPrevPage;
    BOOL _needsToLoadPrevPage;
    NSInteger _isBusyCounter;
    BOOL _isInitialRefreshThumbs;
}

@property(nonatomic) NSUInteger numberOfThumbsPerPage;
@property(nonatomic, retain) UILabel *messageLabel; 
@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, assign) id<PBGridViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame message:(NSString *)message;

- (void)reloadData;
- (void)refreshThumbs;
- (void)setNeedsThumbsLayout;
- (void)layoutThumbsIfNeeded;

- (PBGridViewThumb *)thumbAtIndex:(NSUInteger)idx;

- (BOOL)isBusy;
- (void)showIsBusy:(BOOL)isBusy;


@end
