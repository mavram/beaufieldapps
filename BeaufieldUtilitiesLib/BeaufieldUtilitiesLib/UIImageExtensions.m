//
//  UIImageExtensions.m
//  BeaufieldUtilitiesLib
//
//  Created by mircea on 10-07-27.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "UIImageExtensions.h"


@implementation UIImage(__ResizingExtensions__)

- (UIImage *)imageAtRect:(CGRect)rect {
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* newImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return newImage;
}

- (UIImage *)imageScaledToWidth:(CGFloat)width {

	// Compute height 
	CGFloat height = self.size.height*width/self.size.width;
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	CGImageRef imageRef = [self CGImage];
	CGContextRef context = CGBitmapContextCreate (NULL,
												  width,
												  height,
												  CGImageGetBitsPerComponent(imageRef),
												  CGImageGetBytesPerRow(imageRef),
												  CGImageGetColorSpace(imageRef),
												  CGImageGetAlphaInfo(imageRef));
	if (context == NULL) {
		// error creating context
		return nil;
	}
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(context, CGRectMake(0,0,width, height), imageRef);
	CGImageRef scaledImageRef = CGBitmapContextCreateImage(context);
	// Make ab UIImage out of it
	UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef];
	// Cleanup
	CGImageRelease(scaledImageRef);
	CGContextRelease(context);

	return scaledImage;
}


@end
