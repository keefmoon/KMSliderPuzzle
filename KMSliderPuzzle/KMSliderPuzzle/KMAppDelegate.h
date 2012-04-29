//
//  KMAppDelegate.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 27/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMPuzzleViewController;

@interface KMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KMPuzzleViewController *viewController;

@end
