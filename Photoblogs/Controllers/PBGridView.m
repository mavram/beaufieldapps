//
//  PBGridView.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBGridView.h"
#import "NSErrorExtensions.h"


@implementation PBGridView


BADefineUnitOfWork(refreshThumbs);


static const NSTimeInterval kSlidingAnimationDuration = 0.3;


@synthesize numberOfThumbsPerPage = _numberOfThumbsPerPage;
@synthesize messageLabel = _messageLabel;
@synthesize scrollView = _scrollView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize delegate = _delegate;


- (BOOL)_isLastPage {
    
    if (_numberOfThumbsPerPage == 0) {
        return YES;
    }
    
    if (_numberOfThumbsPerPage < ([_delegate numberOfThumbs] - _numberOfThumbsPerPage*_pageNo)) {
        return NO;
    }

    return YES;
}


- (void)_loadPrevPage {

    _pageNo = _pageNo - 1;
    [_scrollView setContentOffset:CGPointZero];
    
    CGRect offScreenFrame = [_scrollView frame];
    offScreenFrame.origin.y = [self bounds].size.height;
    [UIView animateWithDuration:kSlidingAnimationDuration
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _scrollView.frame = offScreenFrame;
                     } 
                     completion:^(BOOL finished){
                         // move above (off screen)
                         CGRect offScreenFrame = [_scrollView frame];
                         offScreenFrame.origin.y = -[_scrollView bounds].size.height;
                         _scrollView.frame = offScreenFrame;
                         // refresh thumbs
                         [self refreshThumbs];
                         // move on screen
                         CGRect onScreenFrame = [_scrollView frame];
                         onScreenFrame.origin.y = 0;
                         [UIView animateWithDuration:kSlidingAnimationDuration
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              _scrollView.frame = onScreenFrame;
                                          } 
                                          completion:^(BOOL finished){                                              
                                              [self showIsBusy:NO];
                                              _isLoadingPrevPage = NO;
                                          }];
                     }];
}


- (void)_loadNextPage {

    _pageNo = _pageNo + 1;
    [_scrollView setContentOffset:CGPointZero];
    
    CGRect offScreenFrame = [_scrollView frame];
    offScreenFrame.origin.y = -[_scrollView bounds].size.height;
    [UIView animateWithDuration:kSlidingAnimationDuration
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _scrollView.frame = offScreenFrame;
                     } 
                     completion:^(BOOL finished){
                         // move below (off screen)
                         CGRect offScreenFrame = [_scrollView frame];
                         offScreenFrame.origin.y = [self bounds].size.height;
                         _scrollView.frame = offScreenFrame;
                         // refresh thumbs
                         [self refreshThumbs];
                         // move on screen
                         CGRect onScreenFrame = [_scrollView frame];
                         onScreenFrame.origin.y = 0;
                         [UIView animateWithDuration:kSlidingAnimationDuration
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              _scrollView.frame = onScreenFrame;
                                          } 
                                          completion:^(BOOL finished){
                                              [self showIsBusy:NO];
                                              _isLoadingNextPage = NO;
                                          }];
                     }];
}


- (NSUInteger)_numberOfLoadedThumbs {
    
    return [[_scrollView subviews] count];
}


- (id)initWithFrame:(CGRect)frame message:(NSString *)message {
    
    if (![super initWithFrame:frame]) {
        return self;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:NO];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setDelegate:self];
    [_scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    [self addSubview:_scrollView];
    
    _messageLabel = [UILabel new];
    NSString *fontName = @"GillSans";
    CGFloat fontSize = 26;
    CGFloat minimumFontSize = 12;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontName = @"Trebuchet MS";
        fontSize = 14;
        minimumFontSize = 12;
    }
    [_messageLabel setBackgroundColor:[UIColor blackColor]];
    [_messageLabel setTextColor:[UIColor whiteColor]];
    [_messageLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [_messageLabel setMinimumFontSize:minimumFontSize];
    [_messageLabel setTextAlignment:UITextAlignmentCenter];
	[_messageLabel setText:message];
    [_messageLabel setAdjustsFontSizeToFitWidth:YES];
	[_messageLabel setHidden:YES];
	[self addSubview:_messageLabel];
    
    // start on. first refreshThumbs invocation will clear it
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[_activityIndicatorView setHidesWhenStopped:YES];    
    [_activityIndicatorView startAnimating];
    _isBusyCounter = 1;
    _isInitialRefreshThumbs = YES;
    [self addSubview:_activityIndicatorView];

    [self setBackgroundColor:[UIColor blackColor]];
    
    _currentNumberOfColumns = 0;
    _needsThumbsLayout = YES;
    _pageNo = 0;
    _numberOfThumbsPerPage = 0;
    
    _isLoadingNextPage = NO;
    _needsToLoadNextPage = NO;
    _isLoadingPrevPage = NO;
    _needsToLoadPrevPage = NO;
    
    return self;
}


- (void)dealloc {

    [_messageLabel release];
    [_scrollView release];
    [_activityIndicatorView release];

    [super dealloc];
}


- (void) _layoutThumbs {

    // layout
    NSUInteger numberOfLoadedThumbs = [self _numberOfLoadedThumbs];
    CGFloat contentHeight = CGFLOAT_MIN;
    for (NSUInteger i = 0; i < numberOfLoadedThumbs; i++) {;
        UIView *thumbView = [_scrollView viewWithTag:_numberOfThumbsPerPage*_pageNo + i + 1];
        if ((thumbView == nil) || ![thumbView isKindOfClass:[PBGridViewThumb class]]) {
            // thumb views are changed (another _layoutThumbs call). stop here.
            return;
        }
        PBGridViewThumb *thumb = (PBGridViewThumb *)thumbView;
        
        CGFloat x = CGFLOAT_MAX;
        CGFloat y = CGFLOAT_MAX;
        if (i < _currentNumberOfColumns) {
            x = i*([PBGridViewThumb thumbWidth] + [PBGridViewThumb thumbInset]);
            y = 0;
        } else {
            // check previous columns for shortest
            NSMutableArray *visitedColumns = [[[NSMutableArray alloc] init] autorelease];
            NSInteger k = i;
            while ([visitedColumns count] < _currentNumberOfColumns) {
                k = k - 1;
                UIView *previousThumbView = [_scrollView viewWithTag:_numberOfThumbsPerPage*_pageNo + k + 1];
                if ((previousThumbView == nil) || ![previousThumbView isKindOfClass:[PBGridViewThumb class]]) {
                    // thumb views are changed (another _layoutThumbs call). stop here.
                    return;
                }
                PBGridViewThumb *previousThumb = (PBGridViewThumb *)previousThumbView;
                
                CGFloat prevX = [previousThumb frame].origin.x;
                CGFloat prevY = [previousThumb frame].origin.y + [previousThumb thumbHeight] + [PBGridViewThumb thumbInset];
                
                // was column visited
                if ([visitedColumns indexOfObject:[NSNumber numberWithFloat:prevX]] != NSNotFound) {
                    continue;
                } else {
                    // is column shorter or to the left?
                    if (prevY < y) {
                        y = prevY;
                        x = prevX;
                    } else if (prevY == y) {
                        // left most is desirable
                        if (prevX < x) {
                            x = prevX;
                        }
                    }
                    
                    // mark column as visited
                    [visitedColumns addObject:[NSNumber numberWithFloat:prevX]];
                }
            }
        }
        
        [thumb setFrame:CGRectMake(x, y, [PBGridViewThumb thumbWidth], [thumb thumbHeight])];
        [thumb showImage:YES];

#ifdef __DEBUG_LAYOUT_SUBVIEWS__
        [thumb setSubtitle:[NSString stringWithFormat:@"%d %.0f %.0f",
                            _numberOfThumbsPerPage*_pageNo + i,
                            [thumb frame].origin.y,
                            [thumb thumbHeight]]];
#endif

        contentHeight = fmax(contentHeight, [thumb frame].origin.y + [thumb thumbHeight] + [PBGridViewThumb thumbInset]);
    }

    if ([self _isLastPage]) {
        // need to ensure content height allows to move to previous page
        if (contentHeight < [self bounds].size.height) {
            contentHeight = [self bounds].size.height + 7; 
        }
    }
    [_scrollView setContentSize:CGSizeMake([self bounds].size.width, contentHeight)];
    
    _needsThumbsLayout = NO;
}


- (void)layoutSubviews {
    
	if ([self _numberOfLoadedThumbs] == 0) {
        [_messageLabel setFrame:CGRectMake(0, 0, [self bounds].size.width - 20, 100)];
        if ([[_messageLabel text] sizeWithFont:[_messageLabel font]].width > [_messageLabel bounds].size.width) {
            [_messageLabel sizeToFit];
        }
		[_messageLabel setCenter:[self convertPoint:[self center] fromView:[self superview]]];
		[_messageLabel setHidden:NO];
	} else {
		[_messageLabel setHidden:YES];
	}
    
    // compute number of columns
    NSUInteger numberOfColumns = [self bounds].size.width/([PBGridViewThumb thumbWidth] + [PBGridViewThumb thumbInset]);
    if (numberOfColumns != _currentNumberOfColumns) {
        // scrollView needs new bounds
        [_scrollView setFrame:[self bounds]];

        _currentNumberOfColumns = numberOfColumns;
        _needsThumbsLayout = YES;
    }
    
    [self layoutThumbsIfNeeded];
    
    // show busy if needed
    [self bringSubviewToFront:_activityIndicatorView];
    [_activityIndicatorView setCenter:CGPointMake([self center].x, [self bounds].size.height - [_activityIndicatorView frame].size.height)];
    if (_needsToLoadPrevPage || _isLoadingPrevPage) {
        [_activityIndicatorView setCenter:CGPointMake([self center].x, [_activityIndicatorView frame].size.height)];
    }
}


- (void)setNeedsLayout {
    
    [super setNeedsLayout];
    [self setNeedsThumbsLayout];
}


- (void)setNeedsThumbsLayout {

    _needsThumbsLayout = YES;
}


- (void)layoutThumbsIfNeeded {
    
    if (_needsThumbsLayout) {
        [self _layoutThumbs];
    }
}


- (void)reloadData {
    
    // reset pagination
    _pageNo = 0;
    [_scrollView setContentOffset:CGPointZero animated:NO];
    // refresh thumbs
    [self refreshThumbs];
}


- (void)refreshThumbs {

    BABeginUnitOfWork(refreshThumbs);
    
    [self showIsBusy:YES];
    
    // reset scroll view
    NSArray *thumbs = [_scrollView subviews];
    for (UIView *v in thumbs) {
        [v removeFromSuperview];
    }
   
    // set thumbs (make sure not to exceed delegate boundries)
	NSUInteger numberOfThumbsToAdd = _numberOfThumbsPerPage;
    if ([self _isLastPage]) {
        numberOfThumbsToAdd = [_delegate numberOfThumbs] - _numberOfThumbsPerPage*_pageNo;
    } else if (numberOfThumbsToAdd == 0){
        numberOfThumbsToAdd = [_delegate numberOfThumbs];
    }
    for (NSUInteger i = 0; i < numberOfThumbsToAdd; i++) {    
        NSUInteger idx = _numberOfThumbsPerPage*_pageNo + i;
        PBGridViewThumb *gridViewThumb = [_delegate thumbAtIndex:idx];
        [gridViewThumb setTag:idx + 1];

        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleTapFrom:)] autorelease];
        [gridViewThumb addGestureRecognizer:tgr];
        [_scrollView addSubview:gridViewThumb];
    }
    
    // a thumb for "load more". it is just adding it as the last thumb subview - delegate has
    // no involvement in its setup
    if ([self _isLastPage] && [_delegate hasMoreThumbs]) {
        NSString *imageCacheURL = [[[NSBundle mainBundle] URLForResource:@"Thumb-More" withExtension:@"png"] path];
        PBGridViewThumb *gridViewThumb = [[[PBGridViewThumb alloc] initWithImageCacheURL:imageCacheURL
                                                                                   title:nil
                                                                                subtitle:nil
                                                                           defaultHeight:[PBGridViewThumb thumbWidth]] autorelease];
        [gridViewThumb setTag:_numberOfThumbsPerPage*_pageNo + numberOfThumbsToAdd + 1];
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleTapFrom:)] autorelease];
        [gridViewThumb addGestureRecognizer:tgr];
        [_scrollView addSubview:gridViewThumb];
    }
    
    [self showIsBusy:NO];
    if (_isInitialRefreshThumbs) {
        _isInitialRefreshThumbs = NO;
        [self showIsBusy:NO];
    }
   
     _needsThumbsLayout = YES;
    [self setNeedsLayout];

    BAEndUnitOfWork(refreshThumbs);
}


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    PBGridViewThumb *gridViewThumb = (PBGridViewThumb*)[recognizer view];
    
    NSUInteger idx = [gridViewThumb tag];
    if (([self _isLastPage]) && [_delegate hasMoreThumbs] && (idx == [_delegate numberOfThumbs] + 1)) {
        [_delegate fetchThumbs];
    } else {
        [_delegate didSelectThumbAtIndex:idx - 1];
    }
}


#pragma mark - Scroll delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // check if not loading next/prev page already
    if (_isLoadingNextPage || _isLoadingPrevPage) {
        return;
    }
    
    CGFloat currentOffsetY = [_scrollView contentOffset].y;
    CGFloat contentHeight = [_scrollView contentSize].height;
    CGFloat pageHeight = [self bounds].size.height;
    
    if (currentOffsetY > 0) {
        if ((pageHeight - (contentHeight - currentOffsetY)) > 50) {
            if (![self _isLastPage]) {
                if (!_needsToLoadNextPage) {
                    _needsToLoadNextPage = YES;
                    [self showIsBusy:YES];
                }
            }
        } else {
            if (_needsToLoadNextPage) {
                _needsToLoadNextPage = NO;
                [self showIsBusy:NO];
            }
        }
    } else {
        if (currentOffsetY < -50) {
            if (_pageNo > 0) {
                if (!_needsToLoadPrevPage) {
                    _needsToLoadPrevPage = YES;
                    [self showIsBusy:YES];
                }
            }
        } else {
            if (_needsToLoadPrevPage) {
                _needsToLoadPrevPage = NO;
                [self showIsBusy:NO];
            }
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (_needsToLoadNextPage) {
        _needsToLoadNextPage = NO;
        _isLoadingNextPage = YES;
        
        [self performSelector:@selector(_loadNextPage) withObject:nil afterDelay:0.1];

        return;
    }

    if (_needsToLoadPrevPage) {
        _needsToLoadPrevPage = NO;
        _isLoadingPrevPage = YES;
        
        [self performSelector:@selector(_loadPrevPage) withObject:nil afterDelay:0.1];

        return;
    }
}


- (BOOL)isBusy {
    
    return (_isBusyCounter != 0);
}


- (void)showIsBusy:(BOOL)isBusy {
    
    if (isBusy) {
        if (_isBusyCounter == 0) {
            [_activityIndicatorView startAnimating];
        }
        _isBusyCounter = _isBusyCounter + 1;
        //BADebugMessage(@"YES (%d)", _isBusyCounter);
    } else {
        _isBusyCounter = _isBusyCounter - 1;
        //BADebugMessage(@"NO (%d)", _isBusyCounter);
        if (_isBusyCounter == 0) {
            [_activityIndicatorView stopAnimating];
        }
    }
}


- (PBGridViewThumb *)thumbAtIndex:(NSUInteger)idx {
    return (PBGridViewThumb *)[_scrollView viewWithTag:idx + 1];
}


@end
