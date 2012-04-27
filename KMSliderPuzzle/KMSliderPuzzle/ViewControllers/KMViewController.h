//
//  KMViewController.h
//  FBSliderPuzzle
//
//  Created by Keith Moon on 25/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *puzzleView;

@property (nonatomic, retain) NSMutableArray *canvasPatches;

@property (nonatomic, retain) UIPanGestureRecognizer *dragGesture;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;

@end
