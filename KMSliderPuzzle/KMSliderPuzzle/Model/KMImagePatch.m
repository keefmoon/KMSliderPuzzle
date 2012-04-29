//
//  KMImagePatch.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 26/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMImagePatch.h"

@implementation KMImagePatch

@synthesize index;
@synthesize patchImageView;
@synthesize image;
@synthesize isBlank;

- (void)dealloc
{
    self.patchImageView = nil;
    self.image = nil;
    
    [super dealloc];
}

@end
