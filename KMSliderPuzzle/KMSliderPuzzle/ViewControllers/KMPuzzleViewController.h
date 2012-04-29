//
//  KMPuzzleViewController.h
//  FBSliderPuzzle
//
//  Created by Keith Moon on 25/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMPuzzleGame.h"

@interface KMPuzzleViewController : UIViewController

@property (nonatomic, retain) KMPuzzleGame *game;

- (id)initWithGame:(KMPuzzleGame *)puzzleGame;

@end
