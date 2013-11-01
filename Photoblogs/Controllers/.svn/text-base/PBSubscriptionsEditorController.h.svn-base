//
//  PBSubscriptionsEditorController.h
//  Photoblogs
//
//  Created by mircea on 10-07-23.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>

// used for iPhone to dismiss modal
@protocol PBSubscriptionsEditorDelegate <NSObject>

- (void)didEditSubscriptions;

@end


@interface PBSubscriptionsEditorController : UITableViewController {
    
}


@property (nonatomic, retain) NSArray *cachedSubscriptions;
@property (nonatomic) NSUInteger numberOfPhotoblogsSubscriptions;
@property (nonatomic, assign) id<PBSubscriptionsEditorDelegate> delegate;


@end
