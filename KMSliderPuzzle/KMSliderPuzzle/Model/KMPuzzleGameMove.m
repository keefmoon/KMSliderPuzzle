//
//  KMPuzzleGameMove.m
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMPuzzleGameMove.h"

@implementation KMPuzzleGameMove

@synthesize imagePatchesToMove;
@synthesize startCanvasPatches;
@synthesize endCanvasPatches;

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSMutableArray *tempImagePatchesToMove = [[NSMutableArray alloc] init];
        self.imagePatchesToMove = tempImagePatchesToMove;
        [tempImagePatchesToMove release];
        
        NSMutableArray *tempStartCanvasPatches = [[NSMutableArray alloc] init];
        self.startCanvasPatches = tempStartCanvasPatches;
        [tempStartCanvasPatches release];
        
        NSMutableArray *tempEndCanvasPatches = [[NSMutableArray alloc] init];
        self.endCanvasPatches = tempEndCanvasPatches;
        [tempEndCanvasPatches release];
    }
    
    return self;
}

- (void)dealloc
{
    self.imagePatchesToMove = nil;
    
    [super dealloc];
}

@end
