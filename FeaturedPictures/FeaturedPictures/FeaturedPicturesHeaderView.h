//
//  FPPortfolioHeaderView.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-18.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FPHUDView.h"
#import "FPPhoto.h"
#import "FeaturedPicturesGridView.h"


@interface FeaturedPicturesHeaderView : FPHUDView {

}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIImageView *starredPhotoButton;


@end
