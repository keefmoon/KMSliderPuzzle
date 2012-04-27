//
//  KMViewController.m
//  FBSliderPuzzle
//
//  Created by Keith Moon on 25/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMViewController.h"
#import "KMCanvasPatch.h"
#import "KMImagePatch.h"

#define kNoOfRows       4
#define kNoOfColumns    4

@interface KMViewController ()

@property (nonatomic, retain) UIView *draggingView;
@property (nonatomic, assign) CGPoint draggingOffset;

- (void)handlePan:(UIPanGestureRecognizer *)sender;
- (void)handleTap:(UITapGestureRecognizer *)sender;

- (CGFloat)patchWidth;
- (CGFloat)patchHeight;
- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point;

@end

@implementation KMViewController

@synthesize puzzleView;
@synthesize canvasPatches;
@synthesize dragGesture;
@synthesize tapGesture;
@synthesize draggingView;
@synthesize draggingOffset;

#pragma mark - View Controller Lifecycle Mehods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    NSMutableArray *tempCanvaspatches = [[NSMutableArray alloc] initWithCapacity:kNoOfRows*kNoOfColumns];
    self.canvasPatches = tempCanvaspatches;
    [tempCanvaspatches release];
    
    for (int row = 0; row < kNoOfRows; row++) 
    {
        for (int column = 0; column < kNoOfColumns; column++) 
        {
            CGRect patchRect = CGRectMake(column * [self patchWidth], row * [self patchHeight], [self patchWidth], [self patchHeight]);
            
            UIImageView *patchImageView = [[UIImageView alloc] initWithFrame:patchRect];
            
            //TEMP
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
            numberLabel.font = [UIFont systemFontOfSize:20.0f];
            numberLabel.text = [NSString stringWithFormat:@"%d", row*kNoOfColumns+column];
            [patchImageView addSubview:numberLabel];
            [numberLabel release];
            //TEMP
            
            KMImagePatch *imagePatch = [[KMImagePatch alloc] init];
            imagePatch.rowIndex = row;
            imagePatch.columnIndex = row;
            imagePatch.patchImageView = patchImageView;
            
            [self.puzzleView addSubview:patchImageView];
            [patchImageView release];
            
            KMCanvasPatch *canvasPatch = [[KMCanvasPatch alloc] init];
            canvasPatch.rowIndex = row;
            canvasPatch.columnIndex = column;
            canvasPatch.originalRect = patchRect;
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
    // On Pan start keep not of view being dragged and where in the view the first contact point is.
    if (sender.state == UIGestureRecognizerStateBegan) 
    {
        self.draggingView = [self canvasPatchForPoint:[sender locationInView:self.puzzleView]].currentImagePatch.patchImageView;
        self.draggingOffset = self.draggingView.frame.origin;
    }
    // During drag gesture move the view if it is a valid move.
    else if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStatePossible)
    {
        CGPoint dragChange = [sender translationInView:self.puzzleView];
        CGRect patchRect = self.draggingView.frame;
        
        patchRect.origin.x = dragChange.x + self.draggingOffset.x;
        patchRect.origin.y = dragChange.y + self.draggingOffset.y;
        
        self.draggingView.frame = patchRect;
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        // If the drag is less than half the height or width of the view, then revert.
        CGPoint dragChange = [sender translationInView:self.puzzleView];
        
        if (abs(dragChange.x) > [self patchWidth]/2 || abs(dragChange.y) > [self patchHeight]/2) 
        {
            //Complete the move
        }
        else
        {
            //Revert the move
            [UIView animateWithDuration:0.2 animations:^{
                CGRect draggingRect = self.draggingView.frame;
                draggingRect.origin = self.draggingOffset;
                self.draggingView.frame = draggingRect;
            }];
        }
        
        self.draggingView = nil;
        self.draggingOffset = CGPointZero;
    }
    else
    {
        //Need to decide whether to complete or revert.
        
        self.draggingView = nil;
        self.draggingOffset = CGPointZero;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender 
{     
    if (sender.state == UIGestureRecognizerStateEnded)     
    {    
        CGPoint tappedPoint = [sender locationInView:self.puzzleView];
        NSLog(@"Tap happened here: X:%.2f Y:%.2f", tappedPoint.x, tappedPoint.y);
        
        [[self canvasPatchForPoint:tappedPoint].currentImagePatch.patchImageView setBackgroundColor:[UIColor grayColor]];
    } 
}

#pragma mark - Patch Helper Methods

- (CGFloat)patchWidth
{
    return self.puzzleView.frame.size.width / kNoOfColumns;
}

- (CGFloat)patchHeight
{
    return self.puzzleView.frame.size.height / kNoOfRows;
}

- (KMCanvasPatch *)canvasPatchForPoint:(CGPoint)point
{
    NSUInteger patchRow = floorf(point.y / [self patchHeight]);
    NSUInteger patchColumn = floorf(point.x / [self patchWidth]);
    NSUInteger patchIndex = (patchRow * kNoOfColumns) + patchColumn;
    
    return [self.canvasPatches objectAtIndex:patchIndex];
}
                                               
@end
