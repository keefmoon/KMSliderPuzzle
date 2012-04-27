//
//  KMCanvasPatch.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 26/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMCanvasPatch.h"

@implementation KMCanvasPatch

@synthesize columnIndex;
@synthesize rowIndex;
@synthesize originalRect;
@synthesize correctImagePatch;
@synthesize currentImagePatch;

- (void)dealloc
{
    self.correctImagePatch = nil;
    self.currentImagePatch = nil;
    
    [super dealloc];
}

@end
