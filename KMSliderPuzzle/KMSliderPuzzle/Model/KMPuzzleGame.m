//
//  KMPuzzleGame.m
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMPuzzleGame.h"
#import "KMImagePatch.h"
#import "KMDebugMarco.h"

@interface KMPuzzleGame ()

// Move Validity Methods
- (KMPuzzleGameMove *)validRowMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (KMPuzzleGameMove *)validColumnMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column;

@end

@implementation KMPuzzleGame

@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize moves;
@synthesize canvasPatches;
@synthesize blankImagePatch;

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
    self.blankImagePatch = nil;
    
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
            imagePatch.index = index;
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"globe_%d_%d.png", row, column]];
            
            //If the last one, make it the blank one.
            if (row == numberOfRows-1 && column == numberOfColumns-1) 
            {
                imagePatch.isBlank = YES;
                self.blankImagePatch = imagePatch;
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
    [self outputGameState];
}

#pragma mark - Move Validity Methods
//
// Since for each patch there is only one valid move (or no valid move), the game can determine the move. 
//
- (KMPuzzleGameMove *)validMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    KMPuzzleGameMove *validMove = [self validRowMoveForRow:row andColumn:column];
    // Only a row move or a column move can be valid, so only need to do the other if first isn't valid.
    if (validMove.moveDirection == KMPuzzleGameMoveDirectionNone) 
    {
        validMove = [self validColumnMoveForRow:row andColumn:column];
    }
    [validMove outputMoveDetails];
    return validMove;
}

- (KMPuzzleGameMove *)validRowMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    KMPuzzleGameMove *validMove = [[[KMPuzzleGameMove alloc] init] autorelease];
    validMove.moveDirection = KMPuzzleGameMoveDirectionNone;
    
    BOOL inValidRange = NO;
    
    for (int index = row * numberOfColumns; index < row * numberOfColumns + numberOfColumns; index++) 
    {
        KMCanvasPatch *canvasPatchToCheck = [self.canvasPatches objectAtIndex:index];
        
        if (inValidRange) 
        {
            if (canvasPatchToCheck.currentImagePatch.isBlank) 
            {
                inValidRange = NO;
                // If the blank patch is at the end, the valid move is right
                validMove.moveDirection = KMPuzzleGameMoveDirectionRight;
            }
            
            if (inValidRange) 
            {
                [validMove.startCanvasPatches addObject:canvasPatchToCheck];
            }
            
            if (index == [self indexForRow:row andColumn:column]) 
            {
                inValidRange = NO;
            }
        }
        else 
        {
            if (index == [self indexForRow:row andColumn:column]) 
            {
                inValidRange = YES;
                [validMove.startCanvasPatches addObject:canvasPatchToCheck];
            }
            else if (canvasPatchToCheck.currentImagePatch.isBlank) 
            {
                inValidRange = YES;
                // If the blank patch is at the beginning, the valid move is left
                validMove.moveDirection = KMPuzzleGameMoveDirectionLeft;
            }
        }
    }
    
    for (KMCanvasPatch *startCanvasPatch in validMove.startCanvasPatches) 
    {
        [validMove.imagePatchesToMove addObject:startCanvasPatch.currentImagePatch];
        
        if (validMove.moveDirection == KMPuzzleGameMoveDirectionLeft) 
        {
            KMCanvasPatch *endCanvasPatch = [canvasPatches objectAtIndex:startCanvasPatch.index-1];
            [validMove.endCanvasPatches addObject:endCanvasPatch];
        }
        else if (validMove.moveDirection == KMPuzzleGameMoveDirectionRight) 
        {
            KMCanvasPatch *endCanvasPatch = [canvasPatches objectAtIndex:startCanvasPatch.index+1];
            [validMove.endCanvasPatches addObject:endCanvasPatch];
        }
        
    }
    
    return validMove;
}

- (KMPuzzleGameMove *)validColumnMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    KMPuzzleGameMove *validMove = [[[KMPuzzleGameMove alloc] init] autorelease];
    validMove.moveDirection = KMPuzzleGameMoveDirectionNone;
    
    BOOL inValidRange = NO;
    
    for (int index = column; index < self.canvasPatches.count; index = index + numberOfColumns) 
    {
        KMCanvasPatch *canvasPatchToCheck = [self.canvasPatches objectAtIndex:index];
        
        if (inValidRange) 
        {
            if (canvasPatchToCheck.currentImagePatch.isBlank) 
            {
                inValidRange = NO;
                // If the blank patch is at the end, the valid move is down
                validMove.moveDirection = KMPuzzleGameMoveDirectionDown;
            }
            
            if (inValidRange) 
            {
                [validMove.startCanvasPatches addObject:canvasPatchToCheck];
            }
            
            if (index == [self indexForRow:row andColumn:column]) 
            {
                inValidRange = NO;
            }
        }
        else 
        {
            if (index == [self indexForRow:row andColumn:column]) 
            {
                inValidRange = YES;
                [validMove.startCanvasPatches addObject:canvasPatchToCheck];
            }
            
            if (canvasPatchToCheck.currentImagePatch.isBlank) 
            {
                inValidRange = YES;
                // If the blank patch is at the beginning, the valid move is up
                validMove.moveDirection = KMPuzzleGameMoveDirectionUp;
            }
        }
    }
    
    for (KMCanvasPatch *startCanvasPatch in validMove.startCanvasPatches) 
    {
        [validMove.imagePatchesToMove addObject:startCanvasPatch.currentImagePatch];
        
        if (validMove.moveDirection == KMPuzzleGameMoveDirectionUp) 
        {
            KMCanvasPatch *endCanvasPatch = [canvasPatches objectAtIndex:startCanvasPatch.index-numberOfColumns];
            [validMove.endCanvasPatches addObject:endCanvasPatch];
        }
        else if (validMove.moveDirection == KMPuzzleGameMoveDirectionDown) 
        {
            KMCanvasPatch *endCanvasPatch = [canvasPatches objectAtIndex:startCanvasPatch.index+numberOfColumns];
            [validMove.endCanvasPatches addObject:endCanvasPatch];
        }
        
    }
    
    return validMove;
}

#pragma mark - Index Calc Methods

- (NSUInteger)indexForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    return row * numberOfColumns + column;
}

- (NSUInteger)rowForIndex:(NSUInteger)index
{
    return floorf(index / numberOfColumns);
}

- (NSUInteger)columnForIndex:(NSUInteger)index
{
    return index % numberOfColumns;
}

#pragma mark - Retrieval Methods

- (KMCanvasPatch *)canvasPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    return [canvasPatches objectAtIndex:[self indexForRow:row andColumn:column]];
}

- (UIImage *)imageForRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    return [self canvasPatchAtRow:row andColumn:column].currentImagePatch.image;
}

#pragma mark - Move Completion Methods

- (void)completeMove:(KMPuzzleGameMove *)move
{
    for (int index = 0; index < move.startCanvasPatches.count; index++) 
    {
        KMCanvasPatch *endCanvas = [move.endCanvasPatches objectAtIndex:index];
        KMImagePatch *imagePatch = [move.imagePatchesToMove objectAtIndex:index];
        endCanvas.currentImagePatch = imagePatch;
    }
    
    if (move.moveDirection == KMPuzzleGameMoveDirectionUp ||
        move.moveDirection == KMPuzzleGameMoveDirectionLeft) 
    {
        KMCanvasPatch *newBlankPatch = [move.startCanvasPatches objectAtIndex:0];
        newBlankPatch.currentImagePatch = blankImagePatch;
    }
    else if (move.moveDirection == KMPuzzleGameMoveDirectionDown ||
             move.moveDirection == KMPuzzleGameMoveDirectionRight)
    {
        KMCanvasPatch *newBlankPatch = [move.startCanvasPatches lastObject];
        newBlankPatch.currentImagePatch = blankImagePatch;
    }
    
    [self outputGameState];
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
