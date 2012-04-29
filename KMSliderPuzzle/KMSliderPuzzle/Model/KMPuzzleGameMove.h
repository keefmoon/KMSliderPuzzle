//
//  KMPuzzleGameMove.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMPuzzleGameMove : NSObject

@property (nonatomic, retain) NSMutableArray *imagePatchesToMove;
@property (nonatomic, retain) NSMutableArray *startCanvasPatches;
@property (nonatomic, retain) NSMutableArray *endCanvasPatches;

@end
