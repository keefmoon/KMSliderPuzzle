//
//  KMImagePatch.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 26/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMImagePatch.h"

@implementation KMImagePatch

@synthesize patchImageView;
@synthesize isBlank;

- (void)dealloc
{
    self.patchImageView = nil;
    
    [super dealloc];
}

@end
