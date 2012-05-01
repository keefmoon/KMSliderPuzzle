//
//  KMCanvasPatch.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 26/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMCanvasPatch.h"

@implementation KMCanvasPatch

@synthesize index;
@synthesize columnIndex;
@synthesize rowIndex;
@synthesize currentImagePatch;

- (void)dealloc
{
    self.currentImagePatch = nil;
    
    [super dealloc];
}

@end
