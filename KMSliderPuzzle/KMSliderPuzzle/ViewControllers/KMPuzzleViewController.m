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

#define kNoOfRows       5
#define kNoOfColumns    5

// Comment this line in to put a label on each image view that shows the index
//#define DEBUG_LABELS

@interface KMPuzzleViewController ()

@property (nonatomic, retain) IBOutlet UIView *puzzleView;
@property (nonatomic, retain) IBOutlet UILabel *winLabel;
@property (nonatomic, retain) IBOutlet UILabel *movesLabel;
@property (nonatomic, retain) NSMutableArray *patchImageViews;
@property (nonatomic, retain) UIPanGestureRecognizer *dragGesture;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) KMPuzzleGameMove *potentialMove;

// Gesture Handling Methods
- (void)handlePan:(UIPanGestureRecognizer *)sender;
- (void)handleTap:(UITapGestureRecognizer *)sender;

// Game Move Methods
- (void)completePotentialMove;
- (void)cancelPotentialMove;

// Patch Helper Methods
- (CGFloat)patchWidth;
- (CGFloat)patchHeight;
- (CGRect)rectForPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (CGPoint)rectMidPoint:(CGRect)rect;
- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point;
- (NSUInteger)rowForPoint:(CGPoint)point;
- (NSUInteger)columnForPoint:(CGPoint)point;

@end

@implementation KMPuzzleViewController

@synthesize game;
@synthesize puzzleView;
@synthesize patchImageViews;
@synthesize dragGesture;
@synthesize tapGesture;
@synthesize potentialMove;
@synthesize winLabel;
@synthesize movesLabel;

#pragma mark - View Controller Lifecycle Mehods

- (id)initWithGame:(KMPuzzleGame *)puzzleGame
{
    self = [super initWithNibName:@"KMPuzzleViewController" bundle:nil];
    
    if (self) 
    {
        self.game = puzzleGame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Puzzle Game";
    
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
    
    NSMutableArray *tempPatchImageViews = [[NSMutableArray alloc] init];
    self.patchImageViews = tempPatchImageViews;
    [tempPatchImageViews release];
    
    [game generateGame];
    
    //
    // Layout ImageViews
    //
    
    // Will need image views in the array in the order they are initially laid out on screen, so need to
    // fill the array with object so that they can then be swapped out for the correct image view.
    // There is likely a better way to do this though.
    for (KMCanvasPatch *canvasPatch in game.canvasPatches) 
    {
        if (!canvasPatch.currentImagePatch.isBlank) 
        {
            UIImageView *tempImageView = [[UIImageView alloc] init];
            [self.patchImageViews addObject:tempImageView];
            [tempImageView release];
        }
    }
    
    for (KMCanvasPatch *canvasPatch in game.canvasPatches) 
    {
        if (!canvasPatch.currentImagePatch.isBlank) 
        {
            CGRect imageRect = [self rectForPatchAtIndex:canvasPatch.index];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
            imageView.image = canvasPatch.currentImagePatch.image;
            
#ifdef DEBUG_LABELS
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 25, 28)];
            numberLabel.font = [UIFont systemFontOfSize:20.0f];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = [NSString stringWithFormat:@"%d", canvasPatch.currentImagePatch.index];
            [imageView addSubview:numberLabel];
            [numberLabel release];
#endif
            
            [self.patchImageViews replaceObjectAtIndex:canvasPatch.currentImagePatch.index withObject:imageView];
            
            [self.puzzleView addSubview:imageView];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.game = nil;
    self.puzzleView = nil;
    self.winLabel = nil;
    self.movesLabel = nil;
}

- (void)dealloc
{
    self.game = nil;
    self.puzzleView = nil;
    self.patchImageViews = nil;
    self.dragGesture = nil;
    self.tapGesture = nil;
    self.winLabel = nil;
    self.movesLabel = nil;
    
    [super dealloc];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Gesture Handling Methods
                                               
- (void)handlePan:(UIPanGestureRecognizer *)sender 
{     
    if (sender.state == UIGestureRecognizerStateBegan) 
    {
        NSUInteger startRow = [self rowForPoint:[sender locationInView:self.puzzleView]];
        NSUInteger startColumn = [self columnForPoint:[sender locationInView:self.puzzleView]];
        
        self.potentialMove = [game validMoveForRow:startRow andColumn:startColumn];
    }
    else if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStatePossible)
    {
        if (self.potentialMove.moveDirection != KMPuzzleGameMoveDirectionNone) 
        {
            CGPoint dragChange = [sender translationInView:self.puzzleView];
            
            //
            // Limit drag direction and distance based on move direction 
            //
            if (self.potentialMove.moveDirection == KMPuzzleGameMoveDirectionLeft) 
            {
                dragChange.y = 0;
                dragChange.x = MAX(dragChange.x, -[self patchWidth]);
                dragChange.x = MIN(dragChange.x, 0);
            }
            else if (self.potentialMove.moveDirection == KMPuzzleGameMoveDirectionRight) 
            {
                dragChange.y = 0;
                dragChange.x = MIN(dragChange.x, [self patchWidth]);
                dragChange.x = MAX(dragChange.x, 0);
            }
            else if (self.potentialMove.moveDirection == KMPuzzleGameMoveDirectionUp)
            {
                dragChange.x = 0;
                dragChange.y = MAX(dragChange.y, -[self patchHeight]);
                dragChange.y = MIN(dragChange.y, 0);
            }
            else if (self.potentialMove.moveDirection == KMPuzzleGameMoveDirectionDown)
            {
                dragChange.x = 0;
                dragChange.y = MIN(dragChange.y, [self patchHeight]);
                dragChange.y = MAX(dragChange.y, 0);
            }
            
            for (KMCanvasPatch *startCanvas in self.potentialMove.startCanvasPatches) 
            {
                NSUInteger indexToMove = startCanvas.currentImagePatch.index;
                UIImageView *imageView = [self.patchImageViews objectAtIndex:indexToMove];
                CGRect newRect = [self rectForPatchAtIndex:startCanvas.index];
                newRect = CGRectOffset(newRect, dragChange.x, dragChange.y);
                imageView.frame = newRect;
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.potentialMove.moveDirection != KMPuzzleGameMoveDirectionNone) 
        {
            CGPoint dragChange = [sender translationInView:self.puzzleView];
            
            // If the move is over half the patch then complete
            if (abs(dragChange.x) > [self patchWidth]/2 || abs(dragChange.y) > [self patchHeight]/2) 
            {
                [self completePotentialMove];
            }
            else 
            {
                [self cancelPotentialMove];
            }
        }
        
        self.potentialMove = nil;
    }
    else 
    {
        self.potentialMove = nil;
    }

}

- (void)handleTap:(UITapGestureRecognizer *)sender 
{     
    if (sender.state == UIGestureRecognizerStateEnded)     
    {    
        NSUInteger startRow = [self rowForPoint:[sender locationInView:self.puzzleView]];
        NSUInteger startColumn = [self columnForPoint:[sender locationInView:self.puzzleView]];
        
        self.potentialMove = [game validMoveForRow:startRow andColumn:startColumn];
        
        if (self.potentialMove.moveDirection != KMPuzzleGameMoveDirectionNone) 
        {
            [self completePotentialMove];
        }
        
        self.potentialMove = nil;
    } 
}

#pragma mark - Game Move Methods

- (void)completePotentialMove
{
    // Animate completion 
    [UIView animateWithDuration:0.2 animations:^{
        
        for (int index = 0; index < self.potentialMove.startCanvasPatches.count; index++) 
        {
            KMCanvasPatch *startCanvas = [self.potentialMove.startCanvasPatches objectAtIndex:index];
            KMCanvasPatch *endCanvas = [self.potentialMove.endCanvasPatches objectAtIndex:index];
            
            UIImageView *imageView = [self.patchImageViews objectAtIndex:startCanvas.currentImagePatch.index];
            CGRect newRect = [self rectForPatchAtIndex:endCanvas.index];
            imageView.frame = newRect;
        }
    }];
    
    [game completeMove:self.potentialMove];
    
    // Show move count label
    self.movesLabel.text = [NSString stringWithFormat:@"%d", game.moves.count];
    
    // Check if this move completes the game and display the Win label if it does
    self.winLabel.hidden = ![game isGameComplete];
}

- (void)cancelPotentialMove
{
    // Animate revert
    [UIView animateWithDuration:0.2 animations:^{
        
        for (int index = 0; index < self.potentialMove.startCanvasPatches.count; index++) 
        {
            KMCanvasPatch *startCanvas = [self.potentialMove.startCanvasPatches objectAtIndex:index];
            
            UIImageView *imageView = [self.patchImageViews objectAtIndex:startCanvas.currentImagePatch.index];
            CGRect newRect = [self rectForPatchAtIndex:startCanvas.index];
            imageView.frame = newRect;
        }
    }];
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

- (CGRect)rectForPatchAtIndex:(NSInteger)index
{
    NSUInteger patchRow = [game rowForIndex:index];
    NSUInteger patchColumn = [game columnForIndex:index];
    
    return [self rectForPatchAtRow:patchRow andColumn:patchColumn];
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

@end
