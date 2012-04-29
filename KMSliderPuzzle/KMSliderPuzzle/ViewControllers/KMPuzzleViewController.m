//
//  KMViewController.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 25/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMViewController.h"
#import "KMDebugMarco.h"
#import "KMCanvasPatch.h"
#import "KMImagePatch.h"

#define kNoOfRows       4
#define kNoOfColumns    4

@interface KMViewController ()

@property (nonatomic, retain) KMCanvasPatch *draggingStartCanvas;
@property (nonatomic, retain) UIView *draggingView;
@property (nonatomic, assign) CGPoint draggingOffset;

- (void)handlePan:(UIPanGestureRecognizer *)sender;
- (void)handleTap:(UITapGestureRecognizer *)sender;

- (CGFloat)patchWidth;
- (CGFloat)patchHeight;
- (CGPoint)rectMidPoint:(CGRect)rect;
- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point;
- (NSUInteger)rowForPoint:(CGPoint)point;
- (NSUInteger)columnForPoint:(CGPoint)point;
- (KMCanvasPatch *)canvasPatchToSnapTo:(CGRect)imagePatchRect;
- (BOOL)validMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation;
- (BOOL)validMoveInColumn:(NSUInteger)column forRow:(NSUInteger)row andTranslation:(CGPoint)translation;
- (void)outputPatches;

@end

@implementation KMViewController

@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize puzzleView;
@synthesize canvasPatches;
@synthesize dragGesture;
@synthesize tapGesture;
@synthesize draggingStartCanvas;
@synthesize draggingView;
@synthesize draggingOffset;

#pragma mark - View Controller Lifecycle Mehods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOfRows = kNoOfRows;
    self.numberOfColumns = kNoOfColumns;
    
    //
    // Setup Gesture Recognisers
    //
    UIPanGestureRecognizer *tempDragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
                                                                                      action:@selector(handlePan:)];
    self.dragGesture = tempDragGesture;
    [tempDragGesture release];
    self.dragGesture.maximumNumberOfTouches = 1;
    self.dragGesture.minimumNumberOfTouches = 1;
    
    UITapGestureRecognizer *tempTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(handleTap:)];
    self.tapGesture = tempTapGesture;
    [tempTapGesture release];
    
    [self.puzzleView addGestureRecognizer:self.tapGesture];
    [self.puzzleView addGestureRecognizer:self.dragGesture];
    
    //
    // Setup model objects
    //
    NSMutableArray *tempCanvaspatches = [[NSMutableArray alloc] initWithCapacity:numberOfRows*numberOfColumns];
    self.canvasPatches = tempCanvaspatches;
    [tempCanvaspatches release];
    
    for (int row = 0; row < numberOfRows; row++) 
    {
        for (int column = 0; column < numberOfColumns; column++) 
        {
            CGRect patchRect = CGRectMake(column * [self patchWidth], row * [self patchHeight], [self patchWidth], [self patchHeight]);
            
            UIImageView *patchImageView = [[UIImageView alloc] initWithFrame:patchRect];
            
            //TEMP
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
            numberLabel.font = [UIFont systemFontOfSize:20.0f];
            numberLabel.text = [NSString stringWithFormat:@"%d", row*numberOfColumns+column];
            [patchImageView addSubview:numberLabel];
            [numberLabel release];
            //TEMP
            
            KMImagePatch *imagePatch = [[KMImagePatch alloc] init];
            
            //If the last one, make it the blank one.
            if (row == numberOfRows-1 && column == numberOfColumns-1) 
            {
                imagePatch.patchImageView = nil;
                imagePatch.isBlank = YES;
            }
            else 
            {
                imagePatch.patchImageView = patchImageView;
                [self.puzzleView addSubview:patchImageView];
                imagePatch.isBlank = NO;
            }
            
            [patchImageView release];
            
            KMCanvasPatch *canvasPatch = [[KMCanvasPatch alloc] init];
            canvasPatch.rowIndex = row;
            canvasPatch.columnIndex = column;
            canvasPatch.patchRect = patchRect;
            canvasPatch.correctImagePatch = imagePatch;
            canvasPatch.currentImagePatch = imagePatch;
            
            [self.canvasPatches addObject:canvasPatch];
            [canvasPatch release];
            [imagePatch release];
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.puzzleView = nil;
    self.canvasPatches = nil;
    self.draggingView = nil;
}

- (void)dealloc
{
    self.puzzleView = nil;
    self.canvasPatches = nil;
    self.draggingStartCanvas = nil;
    self.dragGesture = nil;
    self.tapGesture = nil;
    
    [super dealloc];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Gesture Handling Methods
                                               
- (void)handlePan:(UIPanGestureRecognizer *)sender 
{     
    // On Pan start keep not of view being dragged and where in the puzzle view the first contact point is.
    if (sender.state == UIGestureRecognizerStateBegan) 
    {
        self.draggingStartCanvas = [self canvasPatchForPoint:[sender locationInView:self.puzzleView]];
        self.draggingView = self.draggingStartCanvas.currentImagePatch.patchImageView;
        self.draggingOffset = self.draggingView.frame.origin;
    }
    // During drag gesture move the view if it is a valid move.
    else if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStatePossible)
    {
        CGPoint dragChange = [sender translationInView:self.puzzleView];
        CGRect patchRect = self.draggingView.frame;
        
        // Only translate in the direction of the valid move.
        if (![self validMoveInRow:self.draggingStartCanvas.rowIndex forColumn:self.draggingStartCanvas.columnIndex andTranslation:dragChange]) 
            dragChange.x = 0;
        
        if (![self validMoveInColumn:self.draggingStartCanvas.columnIndex forRow:self.draggingStartCanvas.rowIndex andTranslation:dragChange]) 
            dragChange.y = 0;
        
        patchRect.origin.x = dragChange.x + self.draggingOffset.x;
        patchRect.origin.y = dragChange.y + self.draggingOffset.y;
        
        self.draggingView.frame = patchRect;
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        // Animate snap to move 
        [UIView animateWithDuration:0.2 animations:^{
            self.draggingView.frame = [self canvasPatchToSnapTo:self.draggingView.frame].patchRect;
        }];
        
        DLog(@"-----BEFORE-----");
        [self outputPatches];
        
        // Update Model
        KMCanvasPatch *toCanvas = [self canvasPatchToSnapTo:self.draggingView.frame];
        KMCanvasPatch *fromCanvas = self.draggingStartCanvas;
        KMImagePatch *swappingImagePatch = toCanvas.currentImagePatch;
        toCanvas.currentImagePatch = fromCanvas.currentImagePatch;
        fromCanvas.currentImagePatch = swappingImagePatch;
        
        DLog(@"-----AFTER-----");
        [self outputPatches];
        
        
        self.draggingView = nil;
        self.draggingStartCanvas = nil;
        self.draggingOffset = CGPointZero;
    }
    else
    {
        self.draggingView = nil;
        self.draggingStartCanvas = nil;
        self.draggingOffset = CGPointZero;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender 
{     
    if (sender.state == UIGestureRecognizerStateEnded)     
    {    
        CGPoint tappedPoint = [sender locationInView:self.puzzleView];
        DLog(@"Tap happened here: X:%.2f Y:%.2f", tappedPoint.x, tappedPoint.y);
        
        [[self canvasPatchForPoint:tappedPoint].currentImagePatch.patchImageView setBackgroundColor:[UIColor grayColor]];
    } 
}

#pragma mark - Patch Helper Methods

- (CGFloat)patchWidth
{
    return self.puzzleView.frame.size.width / numberOfColumns;
}

- (CGFloat)patchHeight
{
    return self.puzzleView.frame.size.height / numberOfRows;
}

- (CGPoint)rectMidPoint:(CGRect)rect
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point
{
    NSUInteger patchRow = [self rowForPoint:point];
    NSUInteger patchColumn = [self columnForPoint:point];
    NSUInteger patchIndex = (patchRow * numberOfColumns) + patchColumn;
    
    return [self.canvasPatches objectAtIndex:patchIndex];
}

- (NSUInteger)rowForPoint:(CGPoint)point
{
    return floorf(point.y / [self patchHeight]);
}

- (NSUInteger)columnForPoint:(CGPoint)point
{
    return floorf(point.x / [self patchWidth]);
}

// Requirement: A less than half way move returns to original point
// and a more than halfway move snaps to the empty patch. 
// Implementation: We can just take the midpoint of the current frame 
// and snap to hich ever canvas patch it is in.

- (KMCanvasPatch *)canvasPatchToSnapTo:(CGRect)imagePatchRect
{
    return [self canvasPatchForPoint:[self rectMidPoint:imagePatchRect]];
}

// If any image patch in the row is the blank one, then there is a valid move.

- (BOOL)validMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation
{
    // If X Translation is negative only blank patches to the left are valid
    // If X Translation is positive only blank patches to the right are valid
    
    int lowerLimit;
    int upperLimit;
    
    if (translation.x < 0) 
    {
        lowerLimit = row * numberOfColumns;
        upperLimit = row * numberOfColumns + column;
    }
    else 
    {
        lowerLimit = row * numberOfColumns + column;
        upperLimit = (row + 1) * numberOfColumns;
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex++) 
    {
        KMCanvasPatch *canvasPatch = [self.canvasPatches objectAtIndex:patchIndex];
        
        if (canvasPatch.currentImagePatch.isBlank) 
            return YES;
    }
    
    return NO;
}

// If any image patch in the column is the blank one, then there is a valid move.

- (BOOL)validMoveInColumn:(NSUInteger)column forRow:(NSUInteger)row andTranslation:(CGPoint)translation
{
    // If Y Translation is negative only blank patches to the above are valid
    // If Y Translation is positive only blank patches to the below are valid
    
    int lowerLimit;
    int upperLimit;
    
    if (translation.y < 0) 
    {
        lowerLimit = column;
        upperLimit = row * numberOfColumns + column;
    }
    else 
    {
        lowerLimit = row * numberOfColumns + column;
        upperLimit = self.canvasPatches.count;
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex = patchIndex + numberOfRows) 
    {
        KMCanvasPatch *canvasPatch = [self.canvasPatches objectAtIndex:patchIndex];
        
        if (canvasPatch.currentImagePatch.isBlank) 
            return YES;
    }
    
    return NO;
}

- (void)outputPatches
{
    int index = 0;
    for (KMCanvasPatch *patch in self.canvasPatches) 
    {
        DLog(@"Index: %d Row: %d Col: %d Currently Blank: %d", index, patch.rowIndex, patch.columnIndex, patch.currentImagePatch.isBlank);
        index++;
    }
}
                                               
@end
