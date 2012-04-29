//
//  KMPuzzleGame.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCanvasPatch.h"

@interface KMPuzzleGame : NSObject

@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, retain) NSMutableArray *moves;
@property (nonatomic, retain) NSMutableArray *canvasPatches;

- (id)initWithNumberOfRows:(NSUInteger)rows andColumns:(NSUInteger)columns;
- (void)generateGame;
- (KMCanvasPatch *)canvasPatchAtRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (UIImage *)imageForRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (void)outputGameState;

@end
