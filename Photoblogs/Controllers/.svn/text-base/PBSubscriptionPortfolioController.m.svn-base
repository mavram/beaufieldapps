//
//  PBRSubscriptionPortfolioController.m
//  PhotoBlogs
//
//  Created by mircea on 10-07-29.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBSubscriptionPortfolioController.h"
#import "NSErrorExtensions.h"
#import "PBAppDelegate.h"
#import "PBEntryPhotosController.h"
#import "PBPhoto.h"
#import "PBPhotoFrameView.h"
#import "PBModel.h"
#import "PBSubscriptionsViewerController.h"


@implementation PBSubscriptionPortfolioController


@synthesize portfolioView = _portfolioView;
@synthesize entryPhotosControllers = _entryPhotoControllers;
@synthesize subscription = _subscription;
@synthesize cachedEntries = _cachedEntries;
@synthesize actionSheet = _actionSheet;


- (id)initWithSubscription:(PBSubscription *)subscription entryIdx:(NSUInteger)entryIdx {
    
    if (!(self = [super init])) {
        return self;
    }
    
    [self setSubscription:subscription];
    [self setCachedEntries:[_subscription entries]];
	[self setActionSheet:nil];

	_currentEntryIdx = entryIdx;
	_entryPhotoControllers = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    return self;
}


- (PBEntryPhotosController *)_entryPhotosControllerAtIndex:(NSInteger)index {
	for (PBEntryPhotosController *entryPhotosController in _entryPhotoControllers) {
		if ([entryPhotosController entryIdx] == index) {
			return entryPhotosController;
		}
	}

    assert(NO);
}


- (void)_addEntryPhotosControllerAtIndex:(NSInteger)index {
	
	PBEntry *entry = (PBEntry *)[_cachedEntries objectAtIndex:index];    
 	PBEntryPhotosController *entryPhotosController = [[[PBEntryPhotosController alloc] initWithEntry:entry entryIdx:index] autorelease];
	
	if (index >= _currentEntryIdx) {
		[_entryPhotoControllers addObject:entryPhotosController];
		[_portfolioView addSubview:[entryPhotosController view]];
	} else if (index < _currentEntryIdx) {
		[_entryPhotoControllers insertObject:entryPhotosController atIndex:0];
		[_portfolioView insertSubview:[entryPhotosController view] atIndex:0];
	}
}

- (void)loadView {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    _portfolioView = [[PBSubscriptionPortfolioView alloc] initWithFrame:screenBounds];
    [_portfolioView setIteratorDelegate:self];
    [_portfolioView setDelegate:self];
    [self setView:_portfolioView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [_portfolioView addGestureRecognizer:tgr];
    [tgr release];
	
    // current post + previous & next (where applicable)
    if (_currentEntryIdx == 0) {
        [self _addEntryPhotosControllerAtIndex:_currentEntryIdx];
        if ([_cachedEntries count] > 1) {
			[self _addEntryPhotosControllerAtIndex:1];
        }
    } else if (_currentEntryIdx == ([_cachedEntries count] - 1)) {
		[self _addEntryPhotosControllerAtIndex:_currentEntryIdx];
		[self _addEntryPhotosControllerAtIndex:_currentEntryIdx - 1];
    } else {
		[self _addEntryPhotosControllerAtIndex:_currentEntryIdx];
		[self _addEntryPhotosControllerAtIndex:_currentEntryIdx - 1];
		[self _addEntryPhotosControllerAtIndex:_currentEntryIdx + 1];
    }
	
    PBEntryPhotosController *entryPhotosController = [self _entryPhotosControllerAtIndex:_currentEntryIdx];
	[self setTitle: [entryPhotosController title]];

	if ([[entryPhotosController entry] isRead] == NO) {
		if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline] == NO) {
            [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] markEntryAsRead:[entryPhotosController entry]];
		}
	}
}


- (void)viewDidLoad {

    [super viewDidLoad];
    
	UIBarButtonItem *actionsButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(actionsAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = actionsButton;
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:[_subscription title]
                                                                    style:self.navigationItem.backBarButtonItem.style
                                                                   target:self
                                                                   action:@selector(backAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = backButton;
    
	if ([PBPhotoFrameView photoFrameMode] != PBPhotoFrameModeUIKit) {
		[[self navigationController] setNavigationBarHidden:YES animated:YES];
	}
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}


- (void)viewDidUnload {

    [super viewDidUnload];

    [_portfolioView release];
}


- (void)didReceiveMemoryWarning {

    BAErrorMessage(@"Subscription <%@> with <%d> entries." , _subscription, [_cachedEntries count]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}


- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[_entryPhotoControllers release];
    [_subscription release];
    [_cachedEntries release];
    [_portfolioView release];
	[_actionSheet release];

    [super dealloc];
}


- (void)dismissActionSheet {
    [_actionSheet dismissWithClickedButtonIndex:7/*dummy*/ animated:YES];
    [self setActionSheet:nil];
}


- (void)actionsAction:(id)sender {
	
    if (_actionSheet) {
        [self dismissActionSheet];
        return;
    }
    
    PBEntryPhotosController *entryPhotosController = [self _entryPhotosControllerAtIndex:_currentEntryIdx];
    
    NSString *cancelButtonTitle = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cancelButtonTitle = @"Cancel";
    }
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        if ([entryPhotosController currentPhotoCacheURL]) {
            _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:cancelButtonTitle
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Set As Cover", @"Save to Albums", nil] autorelease];
            
            [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [_actionSheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        NSString *starActionItem;
        if ([[entryPhotosController entry] isStarred]) {
            starActionItem = @"Remove Star";
        } else {
            starActionItem = @"Add Star";
        }
        
        if ([entryPhotosController currentPhotoCacheURL]) {
            _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:cancelButtonTitle
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:starActionItem, @"Set As Cover", @"Save to Albums", @"Show Original", nil] autorelease];
        } else {
            _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:cancelButtonTitle
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Show Original", nil] autorelease];
            
        }
        
        [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [_actionSheet showFromBarButtonItem:sender animated:YES];
    }
}


- (void)setSubscriptionCoverWithCurrentPhoto {
    
    NSString *currentPhotoCacheURL = [[self _entryPhotosControllerAtIndex:_currentEntryIdx] currentPhotoCacheURL];
    
    [_subscription setCoverPhotoCacheURL:currentPhotoCacheURL];
    [[PBModel sharedModel] saveContext];

    [[[PBAppDelegate sharedAppDelegate] subscriptionsViewerController] setNeedsToRefreshSubscriptionsCovers:YES];
}


- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)clickedButtonIndex {
	
	PBEntryPhotosController *entryPhotosController = [self _entryPhotosControllerAtIndex:_currentEntryIdx];
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        if ([entryPhotosController currentPhotoCacheURL]) {
            switch (clickedButtonIndex) {
                case 0: { /* cover */
                    [self setSubscriptionCoverWithCurrentPhoto];
                    break;
                }
                case 1: { /* to albums */
                    [entryPhotosController saveCurrentPhotoToAlbums];
                    break;
                }
            }
            
            [self setActionSheet:nil];
        }
    } else {
        if ([entryPhotosController currentPhotoCacheURL]) {
            switch (clickedButtonIndex) {
                case 0: { /* star */
                    [entryPhotosController toggleStar];
                    break;
                }
                case 1: { /* cover */
                    [self setSubscriptionCoverWithCurrentPhoto];
                    break;
                }
                case 2: { /* to albums */
                    [entryPhotosController saveCurrentPhotoToAlbums];
                    break;
                }
                case 3: { /* show original */
                    [entryPhotosController showOriginal];
                    break;
                }
            }
        } else {
            switch (clickedButtonIndex) {
                case 0: { /* show original */
                    [entryPhotosController showOriginal];
                    break;
                }
            }
        }
        
        [self setActionSheet:nil];
    }
}


- (void)backAction:(id)sender {
    
    [self dismissActionSheet];
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)applicationDidEnterBackground:(NSNotification *)note {
    
    if (_actionSheet) {
        [self dismissActionSheet];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat width = scrollView.frame.size.width;
    NSInteger index = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
	
    if (index == _currentEntryIdx) {
		return;
	}

	if (index > _currentEntryIdx) {
		if (_currentEntryIdx < ([_cachedEntries count] - 1)) {
			_currentEntryIdx++;
            
			if (_currentEntryIdx < ([_cachedEntries count] - 1)) {
				if (([_entryPhotoControllers count] < 3) || (_currentEntryIdx > 1)) {
					[self _addEntryPhotosControllerAtIndex:_currentEntryIdx + 1];
				}
				if ([_entryPhotoControllers count] > 3) {
					[_entryPhotoControllers removeObjectAtIndex:0];
				}
			}
		}
	} else if (index < _currentEntryIdx) {
		if (_currentEntryIdx > 0) {
			_currentEntryIdx--;
			if (_currentEntryIdx > 0) {
				if (([_entryPhotoControllers count] < 3) || ((([_cachedEntries count] - 1) - _currentEntryIdx) > 1)) {
					[self _addEntryPhotosControllerAtIndex:_currentEntryIdx - 1];
				}
				if ([_entryPhotoControllers count] > 3) {
					[_entryPhotoControllers removeLastObject];
				}
			}
		}
	}

    PBEntryPhotosController *entryPhotosController = [self _entryPhotosControllerAtIndex:_currentEntryIdx];
	[self setTitle: [entryPhotosController title]];

	if ([[entryPhotosController entry] isRead] == NO) {
		if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline] == NO) {
			[[[PBAppDelegate sharedAppDelegate] googleReaderAccount] markEntryAsRead:[entryPhotosController entry]];
		}
	}
}


- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
	// cycle to the modes: UIKit -> Full Screen
	switch ([PBPhotoFrameView photoFrameMode]) {
		case PBPhotoFrameModeUIKit:
			[[self navigationController] setNavigationBarHidden:YES animated:YES];
			[PBPhotoFrameView setPhotoFrameMode:PBPhotoFrameModeFullScreen];
			break;
		case PBPhotoFrameModeFullScreen:
			[[self navigationController] setNavigationBarHidden:NO animated:YES];
			[PBPhotoFrameView setPhotoFrameMode:PBPhotoFrameModeUIKit];
			break;
	}
	
	[[self view] setNeedsLayout];
    [[self view] layoutIfNeeded];
}


#pragma mark - PBPortfolioIteratorDelegate


- (NSUInteger)numberOfEntries {
    return [_cachedEntries count];
}


- (NSUInteger)currentEntryIndex {
    return _currentEntryIdx;
}


@end
