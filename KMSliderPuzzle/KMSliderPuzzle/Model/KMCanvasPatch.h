//
//  KMCanvasPatch.h
//  FBSliderPuzzle
//
//  Created by Keith Moon on 26/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMImagePatch.h"

@interface KMCanvasPatch : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger columnIndex;
@property (nonatomic, assign) NSUInteger rowIndex;
//@property (nonatomic, assign) CGRect patchRect;
@property (nonatomic, retain) KMImagePatch *correctImagePatch;
@property (nonatomic, retain) KMImagePatch *currentImagePatch;

@end
