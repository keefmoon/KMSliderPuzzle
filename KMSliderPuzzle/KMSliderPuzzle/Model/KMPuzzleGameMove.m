//
//  KMPuzzleGameMove.m
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMPuzzleGameMove.h"
#import "KMDebugMarco.h"
#ifdef DEBUG
#import "KMCanvasPatch.h"
#import "KMImagePatch.h"
#endif

@implementation KMPuzzleGameMove

@synthesize imagePatchesToMove;
@synthesize startCanvasPatches;
@synthesize endCanvasPatches;
@synthesize moveDirection;

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

#pragma mark - Debug Methods

- (void)outputMoveDetails
{
    NSMutableString *outputString = [[NSMutableString alloc] init];
    [outputString appendString:@"\nStart Canvas Indexes: "];
    
    for (KMCanvasPatch *startCanvas in self.startCanvasPatches) 
    {
        [outputString appendFormat:@"%d,", startCanvas.index];
    }
    [outputString appendString:@"\nImage Patch Indexes: "];
    for (KMImagePatch *imagePatch in self.imagePatchesToMove) 
    {
        [outputString appendFormat:@"%d,", imagePatch.index];
    }
    [outputString appendString:@"\nEnd Canvas Indexes: "];
    for (KMCanvasPatch *endCanvas in self.endCanvasPatches) 
    {
        [outputString appendFormat:@"%d,", endCanvas.index];
    }
    
    DLog(@"\n----Move----%@", outputString);
}

@end
