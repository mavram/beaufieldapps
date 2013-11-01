//
//  PBSubscriptionsViewerController.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "NSErrorExtensions.h"
#import "PBSubscriptionsViewerController.h"
#import "PBGoogleReaderAccount.h"
#import "PBModel.h"
#import "PBSubscriptionGridViewThumb.h"
#import "PBSubscriptionPhotosController.h"
#import "PBAppDelegate.h"
#import "PBSubscriptionsEditorController.h"


@implementation PBSubscriptionsViewerController

#define __USE_GRID_PAGINATION__
#ifdef __USE_GRID_PAGINATION__
static NSUInteger kNumberOfThumbsPerGridPage = 48;
#endif


@synthesize needsToRefreshSubscriptionsCovers = _needsToRefreshSubscriptionsCovers;
@synthesize gridView = _gridView;
@synthesize photoblogs = _photoblogs;
@synthesize editorPopoverController = _editorPopoverController;



- (void)_reloadCachedPhotoblogs {

    NSMutableArray *photoblogs = [[NSMutableArray new] autorelease];
    for (PBSubscription *s in [[PBModel sharedModel] subscriptions]) {
        if ([s isPhotoblogValue]) {
            [photoblogs addObject:s];
        }
    }

    [self setPhotoblogs:photoblogs];
}

- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSynchronizeWithServer:)
												 name:kDidSynchronizeWithServerNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [self _reloadCachedPhotoblogs];
    
    [self setEditorPopoverController:nil];
    _needsToRefreshSubscriptionsCovers = YES;
    
	return self;
}


- (void)loadView {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    _gridView = [[PBGridView alloc] initWithFrame:screenBounds message:@"Loading subscriptions..."];
    [_gridView setDelegate:self];
#ifdef __USE_GRID_PAGINATION__
    [_gridView setNumberOfThumbsPerPage:kNumberOfThumbsPerGridPage];
#endif
    [self setView:_gridView];
}


- (void)viewDidUnload {    

    [super viewDidUnload];
    
    [self setGridView:nil];
    [self setEditorPopoverController:nil];
}


- (void)didReceiveMemoryWarning {

    BAErrorMessage(@"With <%d> photoblogs", [_photoblogs count]);
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    // covers can change, unread counts do change, ... easieast to handle is to refresh thumbs
    // delay will save time when navigating back from photos controller
    if (_needsToRefreshSubscriptionsCovers) {
        [_gridView performSelector:@selector(refreshThumbs) withObject:nil afterDelay:0.1];
        _needsToRefreshSubscriptionsCovers = NO;
    } else {
        // quick and dirty
        NSArray *views = [[_gridView scrollView] subviews];
        for (UIView *v in views) {
            if ([v isKindOfClass:[PBSubscriptionGridViewThumb class]]) {
                PBSubscriptionGridViewThumb *t = (PBSubscriptionGridViewThumb *)v;
                [t refreshUnreadCounts];
            }
        }
    }

    // synchronize with Google
    if (![[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        [self synchronizeWithServer];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}


- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setGridView:nil];
    [self setPhotoblogs:nil];
    [self setEditorPopoverController:nil];
    
    [super dealloc];
}



#pragma mark - PBGoogleReaderAccount notifications


- (void)didSynchronizeWithServer:(NSNotification *)note {

    // we need to reset cached photoblogs and the thumbs
    [self _reloadCachedPhotoblogs];
    
    [_gridView showIsBusy:NO];
    [_gridView reloadData];
}


#pragma mark - PBGridViewDelegate


- (NSUInteger)numberOfThumbs {

    return [_photoblogs count];
}


- (PBGridViewThumb *)thumbAtIndex:(NSUInteger)idx {

    PBSubscriptionGridViewThumb *gridViewThumb = [PBSubscriptionGridViewThumb alloc];
    gridViewThumb = [gridViewThumb initWithSubscription:[_photoblogs objectAtIndex:idx]];
    return [gridViewThumb autorelease];
}


- (void)_showSubscriptionsEditorWithIndex:(NSNumber *)idx {
    
    // cache all subscriptions
    NSMutableArray *cachedSubscriptions = [[NSMutableArray new] autorelease];
    NSArray *subscriptions = [[PBModel sharedModel] subscriptions];
    for (PBSubscription * s in subscriptions) {
        if ([s metaTypeValue] == PBMetaSubscriptionTypeRegular) {
            [cachedSubscriptions addObject:s];
        }
    }
    
    // subscription editor; prepare a controller
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    PBSubscriptionsEditorController *subscriptionsEditorController = [[[PBSubscriptionsEditorController alloc] init] autorelease];
    [subscriptionsEditorController setContentSizeForViewInPopover:CGSizeMake(screenBounds.size.width/2, screenBounds.size.height - 200)];
    [subscriptionsEditorController setCachedSubscriptions:cachedSubscriptions];
    [subscriptionsEditorController setNumberOfPhotoblogsSubscriptions:[_photoblogs count]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // present modal
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:subscriptionsEditorController] autorelease];
        [subscriptionsEditorController setDelegate:self];
        [self presentModalViewController:navigationController animated:YES];
    } else {
        // present popover
        _editorPopoverController = [[UIPopoverController alloc] initWithContentViewController:subscriptionsEditorController];
        [_editorPopoverController setDelegate:self];
        [_editorPopoverController presentPopoverFromRect:[[_gridView thumbAtIndex:[idx intValue]] frame]
                                                  inView:_gridView
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
}


- (void)didSelectThumbAtIndex:(NSUInteger)idx {
    
    // wait until previous work is done
    if ([_gridView isBusy]) {
        return;
    }

    if (idx == ([self numberOfThumbs] - 1)) {        
        [_gridView showIsBusy:YES]; 
        // subscriptions editor is always last
        [self performSelector:@selector(_showSubscriptionsEditorWithIndex:) withObject:[NSNumber numberWithInt:idx] afterDelay:0.1];
    } else {
        // no need to show busy. photos controllers load fast
        PBSubscriptionPhotosController *subscriptionPhotosController = [PBSubscriptionPhotosController alloc];
        PBSubscription *s = [_photoblogs objectAtIndex:idx];
        subscriptionPhotosController = [subscriptionPhotosController initWithSubscription:s];
        [[self navigationController] pushViewController:subscriptionPhotosController animated:YES];
        [subscriptionPhotosController release];
    }
}


- (BOOL)hasMoreThumbs {
    
    return NO;
}


#pragma mark - Popover management


- (void)_postEditSubscriptions {
    
    // stop activity indicator
    [_gridView showIsBusy:NO];
    // refreshed cached photoblogs in case something changed
    [self _reloadCachedPhotoblogs];
    [_gridView reloadData];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {

    [self setEditorPopoverController:nil];
    // delay to allow popover dismissal
    [self performSelector:@selector(_postEditSubscriptions) withObject:nil afterDelay:0.1];
}


- (void)applicationDidEnterBackground:(NSNotification *)note {
    
    // this is for iPad
    if (_editorPopoverController) {
        [_editorPopoverController dismissPopoverAnimated:NO];
        [self setEditorPopoverController:nil];
    }
    
    // this is for iPhone
    if ([self modalViewController]) {
        [self dismissModalViewControllerAnimated:NO];
    }
}


- (void)didEditSubscriptions {
    
    [self dismissModalViewControllerAnimated:YES];
    // delay to allow modal dismissal
    [self performSelector:@selector(_postEditSubscriptions) withObject:nil afterDelay:0.1];
}


- (void)synchronizeWithServer {
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] synchronizeWithServer]) {
        // show some animation
        [_gridView showIsBusy:YES];
    }
}


@end
