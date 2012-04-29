//
//  KMPuzzleViewController.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 25/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMPuzzleViewController.h"
#import "KMDebugMarco.h"
#import "KMCanvasPatch.h"
#import "KMImagePatch.h"
#import "KMPuzzleGameMove.h"

#define kNoOfRows       4
#define kNoOfColumns    4

@interface KMPuzzleViewController ()

@property (nonatomic, retain) IBOutlet UIView *puzzleView;
@property (nonatomic, retain) NSMutableArray *patchImageViews;
@property (nonatomic, retain) UIPanGestureRecognizer *dragGesture;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) KMCanvasPatch *draggingStartCanvas;
@property (nonatomic, retain) UIView *draggingView;
@property (nonatomic, retain) NSMutableArray *allDraggingViews;
@property (nonatomic, assign) CGPoint draggingOffset;
@property (nonatomic, retain) KMPuzzleGameMove *potentialMove;

- (void)handlePan:(UIPanGestureRecognizer *)sender;
- (void)handleTap:(UITapGestureRecognizer *)sender;

- (CGFloat)patchWidth;
- (CGFloat)patchHeight;
- (CGRect)rectForPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (CGPoint)rectMidPoint:(CGRect)rect;
- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point;
- (NSUInteger)rowForPoint:(CGPoint)point;
- (NSUInteger)columnForPoint:(CGPoint)point;
- (KMCanvasPatch *)canvasPatchToSnapTo:(CGRect)imagePatchRect;
- (NSArray *)validPatchesToMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation;
- (NSArray *)validPatchesToMoveInColumn:(NSUInteger)column forRow:(NSUInteger)row andTranslation:(CGPoint)translation;
/*** DEPRECATED ***/
- (BOOL)validMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation;
- (BOOL)validMoveInColumn:(NSUInteger)column forRow:(NSUInteger)row andTranslation:(CGPoint)translation;

@end

@implementation KMPuzzleViewController

@synthesize game;
@synthesize puzzleView;
@synthesize patchImageViews;
@synthesize dragGesture;
@synthesize tapGesture;
@synthesize draggingStartCanvas;
@synthesize draggingView;
@synthesize allDraggingViews;
@synthesize draggingOffset;
@synthesize potentialMove;

#pragma mark - View Controller Lifecycle Mehods

- (id)initWithGame:(KMPuzzleGame *)puzzleGame
{
    NSString *nibName;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nibName = @"KMViewController_iPhone";
    } else {
        nibName = @"KMViewController_iPad";
    }
    
    self = [super initWithNibName:nibName bundle:nil];
    
    if (self) 
    {
        self.game = puzzleGame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    KMPuzzleGame *tempGame = [[KMPuzzleGame alloc] initWithNumberOfRows:kNoOfRows andColumns:kNoOfColumns];
    self.game = tempGame;
    [tempGame release];
    
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
    NSMutableArray *tempPatchImageViews = [[NSMutableArray alloc] initWithCapacity:game.numberOfRows * game.numberOfColumns];
    self.patchImageViews = tempPatchImageViews;
    [tempPatchImageViews release];
    
    [game generateGame];
    
    NSUInteger index = 0;
    
    for (int row = 0; row < game.numberOfRows; row++) 
    {
        for (int column = 0; column < game.numberOfColumns; column++) 
        {
            KMCanvasPatch *canvasPatch = [game canvasPatchAtRow:row andColumn:column];
            CGRect patchRect = [self rectForPatchAtRow:row andColumn:column];           
            
            UIImageView *patchImageView = [[UIImageView alloc] initWithFrame:patchRect];
            patchImageView.image = [game imageForRow:row andColumn:column];
            patchImageView.contentMode = UIViewContentModeScaleToFill;
            
            // This link helps us match the imageView to the model object
            canvasPatch.currentImagePatch.index = index;
            [self.patchImageViews addObject:patchImageView];
            
#ifdef DEBUG
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 25, 28)];
            numberLabel.font = [UIFont systemFontOfSize:20.0f];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = [NSString stringWithFormat:@"%d", canvasPatch.currentImagePatch.index];
            [patchImageView addSubview:numberLabel];
            [numberLabel release];
#endif
            
            if (!canvasPatch.currentImagePatch.isBlank) 
            {
                [self.puzzleView addSubview:patchImageView];
            }
            [patchImageView release];
            
            index++;
        }
    }
    
    [game outputGameState];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.game = nil;
    self.puzzleView = nil;
    self.draggingView = nil;
}

- (void)dealloc
{
    self.game = nil;
    self.puzzleView = nil;
    self.patchImageViews = nil;
    self.draggingStartCanvas = nil;
    self.dragGesture = nil;
    self.tapGesture = nil;
    self.allDraggingViews = nil;
    
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
        KMPuzzleGameMove *tempPotentialMove = [[KMPuzzleGameMove alloc] init];
        self.potentialMove = tempPotentialMove;
        [tempPotentialMove release];
        
        self.draggingStartCanvas = [self canvasPatchForPoint:[sender locationInView:self.puzzleView]];
        self.draggingView = [self.patchImageViews objectAtIndex:self.draggingStartCanvas.currentImagePatch.index];
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
        
        // On first move, determine all the valid imagePatches to move.
        if (self.potentialMove.imagePatchesToMove.count > 0) 
        {
            NSArray *validPatches;
            if (dragChange.x != 0) 
            {
                validPatches = [self validPatchesToMoveInRow:self.draggingStartCanvas.rowIndex 
                                                   forColumn:self.draggingStartCanvas.columnIndex 
                                              andTranslation:dragChange];
            }
            else if (dragChange.y != 0)
            {
                validPatches = [self validPatchesToMoveInColumn:self.draggingStartCanvas.columnIndex 
                                                         forRow:self.draggingStartCanvas.rowIndex 
                                                 andTranslation:dragChange];
            }
            
            for (KMCanvasPatch *canvas in validPatches) 
            {
                [self.potentialMove.startCanvasPatches addObject:canvas];
                [self.potentialMove.imagePatchesToMove addObject:canvas.currentImagePatch];
            }
        }
        
        CGFloat newX = dragChange.x + self.draggingOffset.x;
        CGFloat newY = dragChange.y + self.draggingOffset.y;
        CGRect newRect = CGRectMake(newX, newY, patchRect.size.width, patchRect.size.height);
        
        // Need to limit to bounds of puzzle view
        CGRect totalRect;
        
        //TODO need to hold on to all valid image views.
        
        
        if (CGRectContainsRect(self.puzzleView.bounds,newRect)) 
        {
            self.draggingView.frame = newRect;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        KMCanvasPatch *endCanvasPatch = [self canvasPatchToSnapTo:self.draggingView.frame];
        CGRect newRect = [self rectForPatchAtRow:endCanvasPatch.rowIndex andColumn:endCanvasPatch.columnIndex];
        
        // Animate snap to move 
        [UIView animateWithDuration:0.2 animations:^{
            self.draggingView.frame = newRect;
        }];
        
        DLog(@"\n-----BEFORE-----");
        [game outputGameState];
        
        // Update Model
        KMImagePatch *swappingImagePatch = self.draggingStartCanvas.currentImagePatch;
        self.draggingStartCanvas.currentImagePatch = endCanvasPatch.currentImagePatch;
        endCanvasPatch.currentImagePatch = swappingImagePatch;
        
        DLog(@"\n-----AFTER-----");
        [game outputGameState];
        
        self.potentialMove = nil;
        self.draggingView = nil;
        self.draggingStartCanvas = nil;
        self.draggingOffset = CGPointZero;
    }
    else
    {
        self.potentialMove = nil;
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
    return self.puzzleView.frame.size.width / game.numberOfColumns;
}

- (CGFloat)patchHeight
{
    return self.puzzleView.frame.size.height / game.numberOfRows;
}

- (CGRect)rectForPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    return CGRectMake(column * [self patchWidth], row * [self patchHeight], [self patchWidth], [self patchHeight]);
}

- (CGPoint)rectMidPoint:(CGRect)rect
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point
{
    NSUInteger patchRow = [self rowForPoint:point];
    NSUInteger patchColumn = [self columnForPoint:point];
    
    return [game canvasPatchAtRow:patchRow andColumn:patchColumn];
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
    //CGRect limitedRect = [self innerRect:imagePatchRect shiftedToWithinRect:self.puzzleView.frame];
    return [self canvasPatchForPoint:[self rectMidPoint:imagePatchRect]];
}

#pragma mark - Move Validity Methods

- (NSArray *)validPatchesToMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation
{
    // Collect valid imagePatches that are valid to move
    NSMutableArray *validImagePatches = [NSMutableArray array];
    
    // If X Translation is negative only blank patches to the left are valid
    // If X Translation is positive only blank patches to the right are valid
    
    int lowerLimit;
    int upperLimit;
    
    if (translation.x < 0) 
    {
        lowerLimit = row * game.numberOfColumns;
        upperLimit = MIN(row * game.numberOfColumns + column, game.canvasPatches.count);
    }
    else 
    {
        lowerLimit = row * game.numberOfColumns + column;
        upperLimit = MIN((row + 1) * game.numberOfColumns, game.canvasPatches.count);
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex++) 
    {
        KMCanvasPatch *canvasPatch = [game.canvasPatches objectAtIndex:patchIndex];
        [validImagePatches addObject:canvasPatch];
        
        if (canvasPatch.currentImagePatch.isBlank) 
        {
            return (NSArray *)validImagePatches;
        }
    }
    
    return nil;
}

- (NSArray *)validPatchesToMoveInColumn:(NSUInteger)column forRow:(NSUInteger)row andTranslation:(CGPoint)translation
{
    // Collect valid imagePatches that are valid to move
    NSMutableArray *validImagePatches = [NSMutableArray array];
    
    // If Y Translation is negative only blank patches to the above are valid
    // If Y Translation is positive only blank patches to the below are valid
    
    int lowerLimit;
    int upperLimit;
    
    if (translation.y < 0) 
    {
        lowerLimit = column;
        upperLimit = MIN(row * game.numberOfColumns + column, game.canvasPatches.count);
    }
    else 
    {
        lowerLimit = row * game.numberOfColumns + column;
        upperLimit = game.canvasPatches.count;
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex = patchIndex + game.numberOfRows) 
    {
        KMCanvasPatch *canvasPatch = [game.canvasPatches objectAtIndex:patchIndex];
        [validImagePatches addObject:canvasPatch];
        
        if (canvasPatch.currentImagePatch.isBlank) 
        {
            return (NSArray *)validImagePatches;
        }
    }
    
    return nil;
}




/*** DEPRECATED ***/

- (BOOL)validMoveInRow:(NSUInteger)row forColumn:(NSUInteger)column andTranslation:(CGPoint)translation
{
    // If X Translation is negative only blank patches to the left are valid
    // If X Translation is positive only blank patches to the right are valid
    
    int lowerLimit;
    int upperLimit;
    
    if (translation.x < 0) 
    {
        lowerLimit = row * game.numberOfColumns;
        upperLimit = MIN(row * game.numberOfColumns + column, game.canvasPatches.count);
    }
    else 
    {
        lowerLimit = row * game.numberOfColumns + column;
        upperLimit = MIN((row + 1) * game.numberOfColumns, game.canvasPatches.count);
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex++) 
    {
        KMCanvasPatch *canvasPatch = [game.canvasPatches objectAtIndex:patchIndex];
        
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
        upperLimit = MIN(row * game.numberOfColumns + column, game.canvasPatches.count);
    }
    else 
    {
        lowerLimit = row * game.numberOfColumns + column;
        upperLimit = game.canvasPatches.count;
    }
    
    for (int patchIndex = lowerLimit; patchIndex < upperLimit; patchIndex = patchIndex + game.numberOfRows) 
    {
        KMCanvasPatch *canvasPatch = [game.canvasPatches objectAtIndex:patchIndex];
        
        if (canvasPatch.currentImagePatch.isBlank) 
            return YES;
    }
    
    return NO;
}

@end
