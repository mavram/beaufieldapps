//
//  PBSubscriptionPhotosController.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "NSErrorExtensions.h"
#import "PBSubscriptionPhotosController.h"
#import "PBGoogleReaderAccount.h"
#import "PBModel.h"
#import "PBEntry.h"
#import "PBPhotoGridViewThumb.h"
#import "PBAppDelegate.h"
#import "PBPhotoManager.h"
#import "PBSubscriptionPortfolioController.h"


static NSUInteger kNumberOfThumbsPerGridPage = 20;


@implementation PBSubscriptionPhotosController

@synthesize gridView = _gridView;
@synthesize subscription = _subscription;
@synthesize cachedEntries = _cachedEntries;
@synthesize actionSheet = _actionSheet;


- (id)initWithSubscription:(PBSubscription *)subscription {
    
    if (!(self = [super init])) {
        return self;
    }
    
    [self setSubscription:subscription];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFetchEntries:)
												 name:kDidFetchEntriesNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchThumbPhoto:)
                                                 name:kDidFetchThumbPhotoNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didToggleStarredFlag:)
                                                 name:kDidToggleStarredFlagNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [self setCachedEntries:[_subscription entries]];
    [self setActionSheet:nil];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    //BADebugMessage(@"Did load <%@> with <%d> entries.", [_subscription title], [_cachedEntries count]);
#endif    
    
    return self;
}


- (NSString *)_gridMessage {
    
    NSString *message = @"Loading photos...";

    if (([self numberOfThumbs] == 0) && ([self hasMoreThumbs] == NO)) {
        if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
            message = @"No new photos.";
        } else if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeStarredPhotos) {
            message = @"No starred photos.";
        } else if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeRegular) {
            message = [NSString stringWithFormat:@"\"%@\" has no photos.", [_subscription title], nil];
        }
    }
    return message;
}


- (void) _setupActionsButton {
    
    if ([_subscription numberOfEntries] == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        return;
    }
    
    // if new photos we have unread entries otherwise we need to empty cache.
    // either or we display the actions button
    
    UIBarButtonItem *actionsButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                    target:self
                                                                                    action:@selector(actionsAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = actionsButton;
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:[_subscription title]
                                                                    style:self.navigationItem.backBarButtonItem.style
                                                                   target:self
                                                                   action:@selector(backAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = backButton;
}


- (void)_refreshThumbs {

    [self setCachedEntries:[_subscription entries]];
    [[_gridView messageLabel] setText:[self _gridMessage]];
    [self _setupActionsButton];
    [_gridView reloadData];
}


- (void)loadView {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    _gridView = [[PBGridView alloc] initWithFrame:screenBounds message:[self _gridMessage]];
    [_gridView setDelegate:self];
    [_gridView setNumberOfThumbsPerPage:kNumberOfThumbsPerGridPage];
    [self setView:_gridView];
    
    // load thumbs (with delay). if no delay tapping subscription thumb has a lag
    [_gridView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        return;
    }
    
    [self _setupActionsButton];
}


- (void)viewDidUnload {    

    [super viewDidUnload];

    [self setGridView:nil];
}


- (void)didReceiveMemoryWarning {

    BAErrorMessage(@"With <%d> photos", [PBEntry numberOfEntriesWithSubscription:_subscription]);
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    // if no more entries left it means we have no more unread for newPhotos
    // or no entries at all for regular i.e. nothing cached
    if ([_subscription numberOfEntries] != [_cachedEntries count]) {
        [self _refreshThumbs];
    }
    
    [self setTitle:[_subscription title]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setCachedEntries:nil];
    [self setGridView:nil];
    [self setSubscription:nil];
    [self setActionSheet:nil];
    
    [super dealloc];
}


#pragma mark - PBGridViewDelegate


- (NSUInteger)numberOfThumbs {
     
    return [_cachedEntries count];
}


- (PBGridViewThumb *)thumbAtIndex:(NSUInteger)idx {

    PBEntry *entry = [_cachedEntries objectAtIndex:idx];
    return [[[PBPhotoGridViewThumb alloc] initWithEntry:entry parent:self] autorelease];
}


- (void)didSelectThumbAtIndex:(NSUInteger)idx {

    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isFetchingEntries]) {
        return;
    }

    PBSubscriptionPortfolioController *c = [[PBSubscriptionPortfolioController alloc] initWithSubscription:_subscription
                                                                                                  entryIdx:idx];
    [[self navigationController] pushViewController:c animated:YES];
	[c release];
}


- (BOOL)hasMoreThumbs {
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        return NO;
    }
    return ![_subscription isAtEndValue];
}


- (void)fetchThumbs {
    
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline]) {
        return;
    }
    if ([[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isFetchingEntries]) {
        return;
    }
    
    // show some animation
    [_gridView showIsBusy:YES];
    [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] fetchPhotoblogsEntriesWithFeedURL:[_subscription feedURL]
                                                                               numberOfEntries:kNumberOfThumbsPerGridPage];
}


#pragma mark - PBGoogleReaderAccount notifications


- (void)didFetchEntries:(NSNotification *)note {

    // is for us?
    NSURL *feedURL = (NSURL *)[note object];
    if (![[_subscription feedURL] isEqual:feedURL]) {
        return;
    }

    // reset cached entries
    [self setCachedEntries:[_subscription entries]];
    // reset navigation bar
    [self _setupActionsButton];
    // done fetching
    [_gridView showIsBusy:NO];
    // refresh grid view
    [_gridView refreshThumbs];
}


- (void)didToggleStarredFlag: (NSNotification *)note {
    
	if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeStarredPhotos) {
		[[self navigationController] popToViewController:self animated:YES];
        // let viewWillAppear reload starred photos
	}
}


#pragma mark - PBPhotoGridViewThumb notifications


- (void)didFetchThumbPhoto:(NSNotification *)note {
    
    // layout thumbs as height may change
    [_gridView setNeedsThumbsLayout];
    [_gridView layoutThumbsIfNeeded];
}


# pragma mark - Action Sheet management


- (void)dismissActionSheet {
    [_actionSheet dismissWithClickedButtonIndex:7/*dummy*/ animated:YES];
    [self setActionSheet:nil];
}


- (void)actionsAction:(id)sender {
	
    if (_actionSheet) {
        [self dismissActionSheet];
        return;
    }

    NSString *cancelButtonTitle = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cancelButtonTitle = @"Cancel";
    }
    
    if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:cancelButtonTitle
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Mark All As Read", nil] autorelease];
    } else {
        // some entries must be cached otherwise we won't reach this code path
        NSString *destructiveButtonTitle = @"Delete Cached Photos";
        if ([_subscription numberOfUnreadEntries]) {
            _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:cancelButtonTitle
                                          destructiveButtonTitle:destructiveButtonTitle
                                               otherButtonTitles:@"Mark All As Read", nil] autorelease];
        } else {
            _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:cancelButtonTitle
                                          destructiveButtonTitle:destructiveButtonTitle
                                               otherButtonTitles:nil] autorelease];        
        }
    }
	
	[_actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}


- (void) _markAllAsRead {

    for (PBEntry *entry in [_subscription unreadEntries]) {
        [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] markEntryAsRead:entry];
    }

    if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        // we need to refresh thumbs
        [self _refreshThumbs];
    }
}


- (void) _deleteCachedPhotos {

    // delete cached entries
    [_subscription deleteAllEntries];
    // reset continuation for the feed 
    [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] resetFeedContinuation:[_subscription feedURL]];
    // refresh is required for gridView to reload thumbs
    [self _refreshThumbs];

}


- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)clickedButtonIndex {
    
    if ([_subscription metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        switch (clickedButtonIndex) {
            case 0: { /* mark all as read */
                [self _markAllAsRead];
                break;
            }
        }
    } else {
        switch (clickedButtonIndex) {
            case 0: { /* delete cached photos  */
                [self _deleteCachedPhotos];
                break;
            }
            case 1: { /* mark all as read */
                [self _markAllAsRead];
                break;
            }
        }        
    }
	
	[self setActionSheet:nil];
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


@end
