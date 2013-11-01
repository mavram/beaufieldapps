//
//  FeaturedPicturesController.m
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "NSErrorExtensions.h"
#import "FeaturedPicturesController.h"
#import "FeaturedPicturesAppDelegate.h"
#import "FPPhotoFrameController.h"
#import "FPWikipediaManager.h"
#import "FeaturedPicturesView.h"


static const NSTimeInterval kSlidingAnimationDuration = 0.3;
static const CGFloat kPagingScrollViewPadding = 10.0;


@interface FeaturedPicturesController (__Internal__)

- (void)toggleHeader;
- (BOOL)isHeaderHidden;
- (BOOL)isLocationInHeader:(CGPoint)location;

- (void)toggleGrid;
- (BOOL)isGridHidden;
- (BOOL)isLocationInGrid:(CGPoint)location;

- (CGSize)contentSizeForPagingScrollView;
- (void)addPhotoFrameControllerAtIndex:(NSInteger)index;
- (void)reloadPhotoFrames;
- (void)refreshPhotosWithYear:(NSUInteger) year month:(NSUInteger)month;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPhotoFrameViewAtIndex:(NSUInteger)index;
    
@end


@implementation FeaturedPicturesController

@synthesize month = _month;
@synthesize year = _year;
@synthesize showOnlyStarredPhotos = _showOnlyStarredPhotos;

@synthesize photos = _photos;
@synthesize currentPhotoIndex = _currentPhotoIndex;

@synthesize headerController = _headerController;
@synthesize gridController = _gridController;
@synthesize photoFrameControllers = _photoFrameControllers;
@synthesize featuredPicturesView = _featuredPicturesView;


#pragma mark - Internals


- (void)addPhotoFrameControllerAtIndex:(NSInteger)index {
	
	FPPhoto *photo = (FPPhoto *)[_photos objectAtIndex:index];    
 	FPPhotoFrameController *c = [[[FPPhotoFrameController alloc] initWithPhoto:photo] autorelease];
    CGRect photoFrameViewFrame = [self frameForPhotoFrameViewAtIndex:index];    

    UIView *v = [c viewWithFrame:photoFrameViewFrame];
    [v setTag:index];
	
	if (index >= _currentPhotoIndex) {
		[_photoFrameControllers addObject:c];
        [[_featuredPicturesView pagingScrollView] addSubview:v];
	} else if (index < _currentPhotoIndex) {
		[_photoFrameControllers insertObject:c atIndex:0];
        [[_featuredPicturesView pagingScrollView] insertSubview:v atIndex:0];
	}
}


- (CGSize)contentSizeForPagingScrollView {

    CGRect pagingScrollViewBounds = [[_featuredPicturesView pagingScrollView] bounds];
    return CGSizeMake(pagingScrollViewBounds.size.width*[_photos count], pagingScrollViewBounds.size.height);
}


- (void)reloadPhotoFrames {
    
    // remove existing controllers
    while ([_photoFrameControllers count]) {
        [_photoFrameControllers removeLastObject];
    }
    
    NSUInteger photoIndex = _currentPhotoIndex;
    NSUInteger numberOfPhotos = [_photos count];
    
    // no photos -> no controllers
    if (numberOfPhotos) {
        // current post + previous & next (where applicable)
        if (photoIndex == 0) {
            [self addPhotoFrameControllerAtIndex:photoIndex];
            if (numberOfPhotos > 1) {
                [self addPhotoFrameControllerAtIndex:1];
            }
        } else if (photoIndex == (numberOfPhotos - 1)) {
            [self addPhotoFrameControllerAtIndex:photoIndex - 1];
            [self addPhotoFrameControllerAtIndex:photoIndex];
        } else {
            [self addPhotoFrameControllerAtIndex:photoIndex - 1];
            [self addPhotoFrameControllerAtIndex:photoIndex];
            [self addPhotoFrameControllerAtIndex:photoIndex + 1];
        }
    }

    // offset
    CGRect pagingScrollViewBounds = [[_featuredPicturesView pagingScrollView] bounds];
    CGPoint pagingScrollViewContentOffset = CGPointMake(pagingScrollViewBounds.size.width*_currentPhotoIndex, 0);
    [[_featuredPicturesView pagingScrollView] setContentOffset:pagingScrollViewContentOffset];       

    [_headerController reloadLabels];
}


- (CGRect)frameForPagingScrollView {
    
    CGRect pagingScrollViewFrame = [_featuredPicturesView bounds];
    pagingScrollViewFrame.origin.x -= kPagingScrollViewPadding;
    pagingScrollViewFrame.size.width += 2*kPagingScrollViewPadding;

    return pagingScrollViewFrame;
}

- (CGRect)frameForPhotoFrameViewAtIndex:(NSUInteger)index {
    
    CGRect pagingScrollViewBounds = [[_featuredPicturesView pagingScrollView] bounds];
    CGRect photoFrameViewFrame = CGRectMake(pagingScrollViewBounds.size.width * index + kPagingScrollViewPadding,
                                            0,
                                            pagingScrollViewBounds.size.width - 2*kPagingScrollViewPadding,
                                            pagingScrollViewBounds.size.height);

    
    return photoFrameViewFrame;
}


- (void)refreshPhotosWithYear:(NSUInteger) year month:(NSUInteger)month {
    
    // set new current
    _year = year;
    _month = month;
    // reset index
    _currentPhotoIndex = 0;
    // cache photos
    [self setPhotos:[FPPhoto photosWithYear:_year month:_month]];
}


#pragma mark - Portfolio navigation methods


- (BOOL)moveToNextYear {

    // new current month and year
    NSUInteger currentMonth = _month;
    NSUInteger currentYear = _year;
    
    // move to next year
    if (currentYear < [FPPhoto currentYear]) {
        currentYear = currentYear + 1;
    } else {
        // reach end of featured pictures
        return NO;
    }
    
    [self refreshPhotosWithYear:currentYear month:currentMonth];
    
    return YES;
}


- (BOOL)moveToNextMonth {
    
    // new current month and year
    NSUInteger currentMonth = _month;
    NSUInteger currentYear = _year;
    
    // don't go past most recent month in the db
    if ((currentMonth == [FPPhoto currentMonth]) && (currentYear == [FPPhoto currentYear])) {
        return NO;
    }

    // move to next month
    currentMonth = currentMonth + 1;
    // check if we need to move to next year
    if (currentMonth == 13) {
        // move to january of next year
        if (currentYear < [FPPhoto currentYear]) {
            currentMonth = 1;
            currentYear = currentYear + 1;
        } else {
            // reach end of featured pictures
            return NO;
        }
    }
    
    [self refreshPhotosWithYear:currentYear month:currentMonth];
    
    return YES;
}


- (BOOL)moveToPreviousYear {
    
    // new current month and year
    NSUInteger currentMonth = _month;
    NSUInteger currentYear = _year;
    
    // move to previous year
    if (currentYear > [FPPhoto firstYear]) {
        currentYear = currentYear - 1;
    } else {
        // reach end of featured pictures
        return NO;
    }

    [self refreshPhotosWithYear:currentYear month:currentMonth];
    
    return YES;
}


- (BOOL)moveToPreviousMonth {
    
    // new current month and year
    NSUInteger currentMonth = _month;
    NSUInteger currentYear = _year;

    // move to previous month
    currentMonth = currentMonth - 1;
    // check if we need to move to previous year
    if (currentMonth == 0) {
        // move to december of previous year
        if (currentYear > [FPPhoto firstYear]) {
            currentMonth = 12;
            currentYear = currentYear - 1;
        } else {
            // reach end of featured pictures
            // first month is January 2005
            return NO;
        }
    }

    [self refreshPhotosWithYear:currentYear month:currentMonth];
    
    return YES;
}


- (BOOL)moveToNextPhoto {

    if (_currentPhotoIndex < ([_photos count] - 1)) {
        _currentPhotoIndex = _currentPhotoIndex + 1;        
        return YES;
    }
    
    
    return NO;
}


- (BOOL)moveToPreviousPhoto {
    if (_currentPhotoIndex > 0) {
        _currentPhotoIndex = _currentPhotoIndex - 1;
        return YES;
    }

    return NO;
}

- (BOOL)moveToPhotoAtIndex:(NSUInteger)photoIndex {
    
    if (photoIndex > [_photos count] - 1) {
        return NO;
    }
    
    if (photoIndex == _currentPhotoIndex) {
        return NO;
    }
    
    _currentPhotoIndex = photoIndex;
    
    // refresh UI
    [self reloadPhotoFrames];
    [_headerController reloadLabels];
    
    return YES;
}


- (NSUInteger)numberOfPhotos {
    return [_photos count];
}


- (FPPhoto*)currentPhoto {

    if ([_photos count]) {
        return [_photos objectAtIndex:_currentPhotoIndex];
    }
    
    return nil;
}


#pragma mark View controller rotation methods


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // Here, our pagingScrollView bounds have not yet been updated for the new interface orientation.
    // So this is a good place to calculate the content offset that we will need in the new orientation
    CGFloat offset = [_featuredPicturesView pagingScrollView].contentOffset.x;
    CGFloat pageWidth = [_featuredPicturesView pagingScrollView].bounds.size.width;
    
    if (offset >= 0) {
        _currentPhotoIndex = floorf(offset / pageWidth);
    } else {
        _currentPhotoIndex = 0;
    }    
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // adjust paging scroll view frame
    [[_featuredPicturesView pagingScrollView] setFrame:[self frameForPagingScrollView]];
    
    // recalculate content size based on current orientation
    CGRect pagingScrollViewBounds = [[_featuredPicturesView pagingScrollView] bounds];
    CGSize scrollViewContentSize = CGSizeMake(pagingScrollViewBounds.size.width*[_photos count], pagingScrollViewBounds.size.height);    
    [[_featuredPicturesView pagingScrollView] setContentSize:scrollViewContentSize];
    
    // adjust header view frame
    CGRect headerViewRect = pagingScrollViewBounds;
    headerViewRect.origin.x = 0;
    headerViewRect.size.width -= 2*kPagingScrollViewPadding;
    headerViewRect.size.height = [FeaturedPicturesHeaderController height];
    [[_headerController headerView] setFrame:headerViewRect];
    
    // adjust grid view frame
    CGRect gridViewRect = pagingScrollViewBounds;
    gridViewRect.origin.x = 0;
    gridViewRect.origin.y = gridViewRect.size.height - [FeaturedPicturesGridController height];
    gridViewRect.size.width -= 2*kPagingScrollViewPadding;
    gridViewRect.size.height = [FeaturedPicturesGridController height];    
    [[_gridController gridView] setFrame:gridViewRect];

    // adjust frames of each photo frame view
    for (FPPhotoFrameView *photoFrameView in [[_featuredPicturesView pagingScrollView] subviews]) {
        [photoFrameView setFrame:[self frameForPhotoFrameViewAtIndex:[photoFrameView tag]]];
        [[photoFrameView zoomingScrollView] setFrame:[photoFrameView bounds]];
        [photoFrameView setMaxMinZoomScalesForCurrentBounds];
    }
    
    // offset
    CGPoint scrollViewContentOffset = CGPointMake(pagingScrollViewBounds.size.width*_currentPhotoIndex, 0);
    [[_featuredPicturesView pagingScrollView] setContentOffset:scrollViewContentOffset];
}


#pragma mark - Internals


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }

    _photoFrameControllers = [NSMutableArray new];
    [self refreshPhotosWithYear:[FPPhoto currentYear] month:[FPPhoto currentMonth]];
    
    _headerController = [FeaturedPicturesHeaderController new];
    _gridController = [FeaturedPicturesGridController new];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"%d/%d with %d photos", _month, _year, [_photos count]);
#endif

    return self;
}


#pragma mark - FPWikipediaManager notifications


- (void)didSynchronizeWithWikimedia:(NSNotification *)note {
    
    // unsubscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSArray *photos = (NSArray *)[note object];
    if ([photos count]) {        
        // refresh photos
        [self refreshPhotosWithYear:[FPPhoto currentYear] month:[FPPhoto currentMonth]];
        // refresh UI
        [self reloadPhotoFrames];
        [[_featuredPicturesView pagingScrollView] setContentSize:[self contentSizeForPagingScrollView]];
        [_gridController reloadThumbnails];
    }
    
    // layout view
    [_featuredPicturesView setNeedsLayout];
    [_featuredPicturesView layoutIfNeeded];
}


- (void)didParsePhotos:(NSNotification *)note {
    
    // unsubscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSArray *photos = (NSArray *)[note object];
    if ([photos count]) {        
        [self refreshPhotosWithYear:_year month:_month];
        // refresh UI
        [self reloadPhotoFrames];
        [[_featuredPicturesView pagingScrollView] setContentSize:[self contentSizeForPagingScrollView]];
        [_gridController reloadThumbnails];
    }
    
    // layout view
    [_featuredPicturesView setNeedsLayout];
    [_featuredPicturesView layoutIfNeeded];
}


#pragma mark - Gesture recognizers handling


- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    // wait until parsing is done (or skip if showing only starred photos)
    if ([[FPWikipediaManager sharedWikipediaManager] isParsingPhotos] || _showOnlyStarredPhotos) {
        return;
    }

    BOOL didMove = NO;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        // move to previous month
        if ([recognizer numberOfTouchesRequired] == 1) {
            didMove = [self moveToPreviousMonth];
        } else {
            // move to previous year
            didMove = [self moveToPreviousYear];
        }
    } else {
        // move to next month
        if ([recognizer numberOfTouchesRequired] == 1) {
            didMove = [self moveToNextMonth];
        } else {
            // move to next year
            didMove = [self moveToNextYear];
        }
    }
    
    // check if for movement
    if (!didMove) {
        return;
    }

#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Move to %d/%d", _month, _year);
#endif

    // refresh UI
    [self reloadPhotoFrames];
    [[_featuredPicturesView pagingScrollView] setContentSize:[self contentSizeForPagingScrollView]];
    [_gridController reloadThumbnails];
    
    // start fetching if no photos
    if (([_photos count] == 0) && !_showOnlyStarredPhotos) {
        // register fpr notifications first
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didParsePhotos:)
                                                     name:kDidParsePhotosNotification
                                                   object:nil];
        
        // update current photos
        [[FPWikipediaManager sharedWikipediaManager] parsePhotosWithYear:_year month:_month];
    }
    
    // layout
    [_featuredPicturesView setNeedsLayout];
    [_featuredPicturesView layoutIfNeeded];
}


- (void)handleTapFromHeaderTitleLabel:(UITapGestureRecognizer *)recognizer {
    
    _showOnlyStarredPhotos = !_showOnlyStarredPhotos;
    
    if (_showOnlyStarredPhotos) {
        [_featuredPicturesView setName:@"Wikimedia Favourite Pictures"];
        _currentPhotoIndex = 0;
        [self setPhotos:[FPPhoto allStarredPhotos]];
    } else {
        [_featuredPicturesView setName:@"Wikimedia Featured Pictures"];
        [self refreshPhotosWithYear:_year month:_month];
    }
    [self reloadPhotoFrames];
    [[_featuredPicturesView pagingScrollView] setContentSize:[self contentSizeForPagingScrollView]];
    [_gridController reloadThumbnails];
    
    // layout view
    [_featuredPicturesView setNeedsLayout];
    [_featuredPicturesView layoutIfNeeded];
}


- (void)handleTapFromHeaderSubtitleLabel:(UITapGestureRecognizer *)recognizer {
    
    FPPhoto *currentPhoto = [self currentPhoto];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[currentPhoto photoPageURL]]];
}



- (void)handleTapFromHeader:(UITapGestureRecognizer *)recognizer {
    // nothing to do
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        BADebugMessage(@"Failed to save photo <%@> to albums. Error <%@>", [error localizedDescription], (NSString *)contextInfo);
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex) {
        FPPhoto *currentPhoto = [self currentPhoto];
        UIImage *cachedImage = [currentPhoto cachedImageWithWidth:[FPPhotoFrameController photoWidth]];
        if (cachedImage) {
            UIImageWriteToSavedPhotosAlbum(cachedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), [currentPhoto photoPageURL]);
        }
    }
}


- (void)handleLongPressFromPhoto:(UILongPressGestureRecognizer *)recognizer {
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Save Picture"
                                                             message:@"Are you sure you want to save the current picture to the Photos Album?"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK", nil] autorelease];
        [alertView show];
    }
}


- (void)handleTapFromPhoto:(UITapGestureRecognizer *)recognizer {
    
    if ([self isLocationInGrid:[recognizer locationInView:_featuredPicturesView]]) {
        if ([self isGridHidden]) {
            [self toggleGrid];
            return;
        }
    }
    
    if ([self isLocationInHeader:[recognizer locationInView:_featuredPicturesView]]) {
        if ([self isHeaderHidden]) {
            [self toggleHeader];    
            return;
        }
    }

    if ([self isGridHidden]) {
        if (![self isHeaderHidden]) {
            [self toggleHeader];
        }
    } else {
        [self toggleGrid];
    }
}


#pragma mark - Lifecycle


- (void)loadView {
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    _featuredPicturesView = [[FeaturedPicturesView alloc] initWithFrame:applicationFrame];
    [_featuredPicturesView setLoadingDelegate:self];
    [[_featuredPicturesView pagingScrollView] setDelegate:self];
    // adjust paging scroll view frame to include padding
    [[_featuredPicturesView pagingScrollView] setFrame:[self frameForPagingScrollView]];    
    [_featuredPicturesView setName:@"Wikimedia Featured Pictures"];
    [self setView:_featuredPicturesView];
    
    // header view
    CGRect headerViewRect = [[_featuredPicturesView pagingScrollView] bounds];
    headerViewRect.size.width -= 2*kPagingScrollViewPadding;
    headerViewRect.size.height = [FeaturedPicturesHeaderController height];
    FeaturedPicturesHeaderView *headerView = [[[FeaturedPicturesAppDelegate featuredPicturesController] headerController] viewWithFrame:headerViewRect];
    [_featuredPicturesView addSubview:headerView];
    [_featuredPicturesView bringSubviewToFront:headerView];
    
    // grid view
    CGRect gridViewRect = [[_featuredPicturesView pagingScrollView] bounds];
    gridViewRect.origin.y = gridViewRect.size.height - [FeaturedPicturesGridController height];
    gridViewRect.size.width -= 2*kPagingScrollViewPadding;
    gridViewRect.size.height = [FeaturedPicturesGridController height];    
    FeaturedPicturesGridView *gridView = [[[FeaturedPicturesAppDelegate featuredPicturesController] gridController] viewWithFrame:gridViewRect];
    [_featuredPicturesView addSubview:gridView];
    [_featuredPicturesView bringSubviewToFront:gridView];
    
    // swipe to right - one finger
	UISwipeGestureRecognizer *rsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [rsgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [[_headerController headerView] addGestureRecognizer:rsgr];
	[rsgr release];

    // swipe to right - two fingers
	UISwipeGestureRecognizer *trsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [trsgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [trsgr setNumberOfTouchesRequired:2];
    [[_headerController headerView] addGestureRecognizer:trsgr];
	[trsgr release];
    
    // swipe to left - one finger
	UISwipeGestureRecognizer *lsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [lsgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[_headerController headerView] addGestureRecognizer:lsgr];
	[lsgr release];

    // swipe to left - two fingers
	UISwipeGestureRecognizer *tlsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [tlsgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [tlsgr setNumberOfTouchesRequired:2];
    [[_headerController headerView] addGestureRecognizer:tlsgr];
	[tlsgr release];
    
    // title tap handler
    UITapGestureRecognizer *htltgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromHeaderTitleLabel:)] autorelease];
    [[[_headerController headerView] titleLabel] addGestureRecognizer:htltgr];
    
    // subtitle tap handler
    UITapGestureRecognizer *hstltgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromHeaderSubtitleLabel:)] autorelease];
    [[[_headerController headerView] subtitleLabel] addGestureRecognizer:hstltgr];
    
    // subtitle tap handler
    UITapGestureRecognizer *htgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromHeader:)] autorelease];
    [[_headerController headerView] addGestureRecognizer:htgr];
    
    // tap on photo
    UITapGestureRecognizer *ptgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromPhoto:)] autorelease];
    [_featuredPicturesView addGestureRecognizer:ptgr];

    // long press on photo 
    UILongPressGestureRecognizer *plpgr = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFromPhoto:)] autorelease];
    [plpgr setMinimumPressDuration:0.5];
    [_featuredPicturesView addGestureRecognizer:plpgr];

    // refresh UI
    [self reloadPhotoFrames];
    [[_featuredPicturesView pagingScrollView] setContentSize:[self contentSizeForPagingScrollView]];
    [_gridController reloadThumbnails];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // get the latest featured pictures
    [self syncronizeWithWikimedia];
}


- (void)viewDidUnload {

    [super viewDidUnload];

    // release root view
    [self setFeaturedPicturesView:nil];
}


- (void)didReceiveMemoryWarning {

    BAErrorMessage(@"With <%d> photos." , [_photos count]);
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_photos release];
    [_featuredPicturesView release];
    [_photoFrameControllers release];
    [_headerController release];

    [super dealloc];
}


#pragma mark - FPLoadingDelegate


- (BOOL)isLoaded {
    return [_photos count];
}


- (BOOL)isOffline {
    return [FeaturedPicturesAppDelegate isOffline];
}


- (BOOL)isLoading {
    return [[FPWikipediaManager sharedWikipediaManager] isParsingPhotos];
}


#pragma mark - UIScrollViewDelegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.bounds.size.width;
    NSInteger index = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
    
    NSUInteger numberOfPhotos = [_photos count];
	
    if (index == _currentPhotoIndex) {
		return;
	}
    
	if (index > _currentPhotoIndex) {
        if ([self moveToNextPhoto]) {            
			if (_currentPhotoIndex < (numberOfPhotos - 1)) {
				if (([_photoFrameControllers count] < 3) || (_currentPhotoIndex > 1)) {
					[self addPhotoFrameControllerAtIndex:_currentPhotoIndex + 1];
				}
				if ([_photoFrameControllers count] > 3) {
					[_photoFrameControllers removeObjectAtIndex:0];
				}
			}
        }
	} else if (index < _currentPhotoIndex) {
        if ([self moveToPreviousPhoto]) {
			if (_currentPhotoIndex > 0) {
				if (([_photoFrameControllers count] < 3) || (((numberOfPhotos - 1) - _currentPhotoIndex) > 1)) {
					[self addPhotoFrameControllerAtIndex:_currentPhotoIndex - 1];
				}
				if ([_photoFrameControllers count] > 3) {
					[_photoFrameControllers removeLastObject];
				}
			}
        }
	}
    
    [_headerController reloadLabels];
}


#pragma mark - Public interface


- (void)syncronizeWithWikimedia {

    // NOTE: we can optimize and synchronize once a day
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSynchronizeWithWikimedia:)
                                                 name:kDidParsePhotosNotification
                                               object:nil];
    
    // update current photos
    [[FPWikipediaManager sharedWikipediaManager] parseCurrentPhotos];
}


- (BOOL)_isHeaderHidden {
    
    if ([_headerController headerView].frame.origin.y < 0) {
        return YES;
    }
    
    return NO;
}


- (void)toggleHeader {
    
    UIView *headerView = [_headerController headerView];
    
    if ([self _isHeaderHidden]) {
        CGRect headerViewFrame = [headerView frame];
        headerViewFrame.origin.y = 0;
        [UIView animateWithDuration:kSlidingAnimationDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [headerView setFrame:headerViewFrame];
                         } 
                         completion:^(BOOL finished){
                         }];        
    } else {
        CGRect headerViewFrame = [headerView frame];
        headerViewFrame.origin.y = -2*headerViewFrame.size.height;
        [UIView animateWithDuration:kSlidingAnimationDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [headerView setFrame:headerViewFrame];
                         } 
                         completion:^(BOOL finished){
                         }];        
        [_featuredPicturesView bringSubviewToFront:headerView];
    }
}


- (BOOL)isHeaderHidden {
    
    if ([_headerController headerView].frame.origin.y < 0) {
        return YES;
    }
    
    return NO;
}


- (BOOL)isLocationInHeader:(CGPoint)location {
    
    if (location.y < [[_headerController headerView] bounds].size.height) {
        return YES;
    }
    
    return NO;
}


- (void)toggleGrid {
    
    UIView *gridView = [_gridController gridView];
    
    if ([self isGridHidden]) {
        CGRect gridViewFrame = [gridView frame];
        gridViewFrame.origin.y = [[_featuredPicturesView pagingScrollView] bounds].size.height - gridViewFrame.size.height;
        [UIView animateWithDuration:kSlidingAnimationDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [gridView setFrame:gridViewFrame];
                         } 
                         completion:^(BOOL finished){
                         }];        
    } else {
        CGRect gridViewFrame = [gridView frame];
        gridViewFrame.origin.y = [[_featuredPicturesView pagingScrollView] bounds].size.height;
        [UIView animateWithDuration:kSlidingAnimationDuration
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [gridView setFrame:gridViewFrame];
                         } 
                         completion:^(BOOL finished){
                         }];        
    }
}


- (BOOL)isGridHidden {
    
    if ([_gridController gridView].frame.origin.y >= [[_featuredPicturesView pagingScrollView] bounds].size.height) {
        return YES;
    }
    
    return NO;
}


- (BOOL)isLocationInGrid:(CGPoint)location {
    
    if (location.y > ([[_featuredPicturesView pagingScrollView] bounds].size.height - [[_gridController gridView] bounds].size.height)) {
        return YES;
    }
    
    return NO;
}


@end
