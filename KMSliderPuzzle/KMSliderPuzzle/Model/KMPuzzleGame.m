//
//  KMPuzzleGame.m
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMPuzzleGame.h"
#import "KMImagePatch.h"

@interface KMPuzzleGame ()

@end

@implementation KMPuzzleGame

@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize moves;
@synthesize canvasPatches;

#pragma mark - Object Lifecycle Methods

- (id)initWithNumberOfRows:(NSUInteger)rows andColumns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) 
    {
        NSMutableArray *tempMoves = [[NSMutableArray alloc] init];
        self.moves = tempMoves;
        [tempMoves release];
        
        NSMutableArray *tempCanvaspatches = [[NSMutableArray alloc] init];
        self.canvasPatches = tempCanvaspatches;
        [tempCanvaspatches release];
        
        self.numberOfRows = rows;
        self.numberOfColumns = columns;
    }
    return self;
}

- (void)dealloc
{
    self.moves = nil;
    self.canvasPatches = nil;
    
    [super dealloc];
}

#pragma mark - Game Lifecycle Methods

- (void)generateGame
{
    //
    // Setup model objects
    //
    NSMutableArray *tempCanvaspatches = [[NSMutableArray alloc] initWithCapacity:numberOfRows * numberOfColumns];
    self.canvasPatches = tempCanvaspatches;
    [tempCanvaspatches release];
    
    NSUInteger index = 0;
    
    for (int row = 0; row < numberOfRows; row++) 
    {
        for (int column = 0; column < numberOfColumns; column++) 
        {
            KMImagePatch *imagePatch = [[KMImagePatch alloc] init];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"globe_%d_%d.png", row, column]];
            
            //If the last one, make it the blank one.
            if (row == numberOfRows-1 && column == numberOfColumns-1) 
            {
                imagePatch.isBlank = YES;
            }
            else 
            {
                imagePatch.isBlank = NO;
                imagePatch.image = image;
            }
            
            KMCanvasPatch *canvasPatch = [[KMCanvasPatch alloc] init];
            canvasPatch.index = index;
            canvasPatch.rowIndex = row;
            canvasPatch.columnIndex = column;
            canvasPatch.correctImagePatch = imagePatch;
            canvasPatch.currentImagePatch = imagePatch;
            
            [self.canvasPatches addObject:canvasPatch];
            [canvasPatch release];
            [imagePatch release];
            
            index++;
        }
    }
}

#pragma mark - Retrieval Methods

- (KMCanvasPatch *)canvasPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    NSUInteger index = row * numberOfColumns + column;
    return [canvasPatches objectAtIndex:index];
}

- (UIImage *)imageForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    return [self canvasPatchAtRow:row andColumn:column].currentImagePatch.image;
}

#pragma mark - Debugging Methods

- (void)outputGameState
{
    
#ifdef DEBUG
    
    NSMutableString *output = [[NSMutableString alloc] init];
    
    int count = 0;
    [output appendString:@"\n----GAME STATE START---- \n"];
    
    for (KMCanvasPatch *canvas in self.canvasPatches) 
    {
        NSUInteger imagePatchIndex = canvas.currentImagePatch.index;
        
        if (canvas.currentImagePatch.isBlank) 
        {
            [output appendFormat:@"| ** ", imagePatchIndex];
        }
        else if (imagePatchIndex < 10) 
        {
            [output appendFormat:@"| 0%d ", imagePatchIndex];
        }
        else 
        {
            [output appendFormat:@"| %d ", imagePatchIndex];
        }
        
        count++;
        
        if (count % numberOfColumns == 0) 
        {
            [output appendString:@"| \n"];
        }
    }
    
    [output appendString:@"----GAME STATE END---- \n"];
    
    NSLog(@"%@", output);
         
#endif
    
}

@end
