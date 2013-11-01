//
//  PBSubscriptionsEditorController.m
//  Photoblogs
//
//  Created by mircea on 10-07-23.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBSubscriptionsEditorController.h"
#import "PBAppDelegate.h"
#import "NSErrorExtensions.h"


@implementation PBSubscriptionsEditorController


@synthesize cachedSubscriptions = _cachedSubscriptions;
@synthesize numberOfPhotoblogsSubscriptions = _numberOfPhotoblogsSubscriptions;
@synthesize delegate = _delegate;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                        style:self.navigationItem.backBarButtonItem.style
                                                                       target:self
                                                                       action:@selector(backAction:)] autorelease];
        self.navigationItem.leftBarButtonItem = backButton;
        
        [self setTitle:@"All Subscriptions"];
    }
}


- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    
    [[self tableView] reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)dealloc {
    
    [_cachedSubscriptions release];
    [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cachedSubscriptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *kSubscriptionId = @"kSubscriptionId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSubscriptionId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSubscriptionId] autorelease];
    }
    
    UISwitch *switchControl = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    [switchControl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [switchControl setTag:indexPath.row];
    cell.accessoryView = switchControl;

    PBSubscription *subscription = [_cachedSubscriptions objectAtIndex:indexPath.row];
	if ([subscription isPhotoblogValue]) {
        // if too many images is just killing the table view
        if (_numberOfPhotoblogsSubscriptions < 24) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:[subscription coverPhotoCacheURLValue]];
        } else {
            cell.imageView.image = nil;
        }
        [switchControl setOn:YES];
	} else {
		cell.imageView.image = nil;
		[switchControl setOn:NO];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [subscription title];
    cell.detailTextLabel.text = [subscription identifier];
    
    return cell;
}


- (void)switchAction:(id)sender {

    UISwitch *switchControl = (UISwitch *)sender;
    
    PBSubscription *subscription = [_cachedSubscriptions objectAtIndex:[switchControl tag]];
    [subscription setIsPhotoblog:[NSNumber numberWithBool:[switchControl isOn]]];
    [[PBModel sharedModel] saveContext];
    
    if ([switchControl isOn]) {
        _numberOfPhotoblogsSubscriptions = _numberOfPhotoblogsSubscriptions + 1;
    } else {
        _numberOfPhotoblogsSubscriptions = _numberOfPhotoblogsSubscriptions - 1;
    }
}


- (void)backAction:(id)sender {
    
    [_delegate didEditSubscriptions];
}


@end

