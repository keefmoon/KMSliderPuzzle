//
//  KMPuzzleGame.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCanvasPatch.h"
#import "KMPuzzleGameMove.h"

@interface KMPuzzleGame : NSObject

@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, retain) UIImage *puzzleImage;
@property (nonatomic, retain) NSMutableArray *moves;
@property (nonatomic, retain) NSMutableArray *canvasPatches;
@property (nonatomic, retain) KMImagePatch *blankImagePatch;

#pragma mark - Game Lifecycle Methods
- (id)initWithImage:(UIImage *)image numberOfRows:(NSUInteger)rows andColumns:(NSUInteger)columns;
- (void)generateGame;
- (BOOL)isGameComplete;

#pragma mark - Move Validity Methods
- (KMPuzzleGameMove *)validMoveForRow:(NSUInteger)row andColumn:(NSUInteger)column;

#pragma mark - Index Calc Methods
- (NSUInteger)indexForRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (NSUInteger)rowForIndex:(NSUInteger)index;
- (NSUInteger)columnForIndex:(NSUInteger)index;

#pragma mark - Move Completion Methods
- (void)completeMove:(KMPuzzleGameMove *)move;

#pragma mark - Retrieval Methods
- (KMCanvasPatch *)canvasPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (UIImage *)imageForRow:(NSUInteger)row andColumn:(NSUInteger)column;

#pragma mark - Debug Methods
- (void)outputGameState;

@end
