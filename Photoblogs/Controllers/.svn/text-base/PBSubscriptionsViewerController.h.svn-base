//
//  PBSubscriptionsViewerController.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBGridView.h"
#import "PBSubscriptionsEditorController.h"


@interface PBSubscriptionsViewerController : UIViewController<PBGridViewDelegate, UIPopoverControllerDelegate, PBSubscriptionsEditorDelegate> {

}

@property (nonatomic) BOOL needsToRefreshSubscriptionsCovers;
@property (nonatomic, retain) PBGridView *gridView;
@property (nonatomic, retain) UIPopoverController *editorPopoverController;
@property (nonatomic, retain) NSArray *photoblogs;


- (void)synchronizeWithServer;


@end
