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
@property (nonatomic, retain) KMPuzzleGameMove *potentialMove;

//Gesture Handling Methods
- (void)handlePan:(UIPanGestureRecognizer *)sender;
- (void)handleTap:(UITapGestureRecognizer *)sender;

// Patch Helper Methods
- (CGFloat)patchWidth;
- (CGFloat)patchHeight;
- (CGRect)rectForPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (CGPoint)rectMidPoint:(CGRect)rect;
- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point;
- (NSUInteger)rowForPoint:(CGPoint)point;
- (NSUInteger)columnForPoint:(CGPoint)point;
//- (KMCanvasPatch *)canvasPatchToSnapTo:(CGRect)imagePatchRect;

@end

@implementation KMPuzzleViewController

@synthesize game;
@synthesize puzzleView;
@synthesize patchImageViews;
@synthesize dragGesture;
@synthesize tapGesture;
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
    
    NSMutableArray *tempPatchImageViews = [[NSMutableArray alloc] initWithCapacity:game.numberOfRows * game.numberOfColumns];
    self.patchImageViews = tempPatchImageViews;
    [tempPatchImageViews release];
    
    [game generateGame];
    
    //
    // Layout ImageViews
    //
    for (KMCanvasPatch *canvasPatch in game.canvasPatches) 
    {
        if (!canvasPatch.currentImagePatch.isBlank) 
        {
            CGRect imageRect = [self rectForPatchAtIndex:canvasPatch.currentImagePatch.index];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
            imageView.image = canvasPatch.currentImagePatch.image;
            
#ifdef DEBUG
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 25, 28)];
            numberLabel.font = [UIFont systemFontOfSize:20.0f];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = [NSString stringWithFormat:@"%d", canvasPatch.currentImagePatch.index];
            [imageView addSubview:numberLabel];
            [numberLabel release];
#endif
            
            [self.patchImageViews insertObject:imageView atIndex:canvasPatch.currentImagePatch.index];
            
            [self.puzzleView addSubview:imageView];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.game = nil;
    self.puzzleView = nil;
}

- (void)dealloc
{
    self.game = nil;
    self.puzzleView = nil;
    self.patchImageViews = nil;
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
    if (sender.state == UIGestureRecognizerStateBegan) 
    {
        NSUInteger startRow = [self rowForPoint:[sender locationInView:self.puzzleView]];
        NSUInteger startColumn = [self columnForPoint:[sender locationInView:self.puzzleView]];
        
        self.potentialMove = [game validMoveForRow:startRow andColumn:startColumn];
    }
    else if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStatePossible)
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
            CGRect newRect = [self rectForPatchAtIndex:indexToMove];
            newRect = CGRectOffset(newRect, dragChange.x, dragChange.y);
            imageView.frame = newRect;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint dragChange = [sender translationInView:self.puzzleView];
        
        if (dragChange.x > [self patchWidth]/2 || dragChange.y > [self patchHeight]/2) 
        {
            // Animate snap to move 
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
        }
        else 
        {
            // Animate snap to move 
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
        CGPoint tappedPoint = [sender locationInView:self.puzzleView];
        DLog(@"Tap happened here: X:%.2f Y:%.2f", tappedPoint.x, tappedPoint.y);
        
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

//// Requirement: A less than half way move returns to original point
//// and a more than halfway move snaps to the empty patch. 
//// Implementation: We can just take the midpoint of the current frame 
//// and snap to hich ever canvas patch it is in.
//
//- (KMCanvasPatch *)canvasPatchToSnapTo:(CGRect)imagePatchRect
//{
//    //CGRect limitedRect = [self innerRect:imagePatchRect shiftedToWithinRect:self.puzzleView.frame];
//    return [self canvasPatchForPoint:[self rectMidPoint:imagePatchRect]];
//}

@end
