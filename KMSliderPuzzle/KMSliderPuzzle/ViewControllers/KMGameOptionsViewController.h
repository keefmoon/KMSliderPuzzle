//
//  KMGameOptionsViewController.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 01/05/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMGameOptionsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISlider *rowSlider;
@property (nonatomic, retain) IBOutlet UISlider *columnSlider;
@property (nonatomic, retain) IBOutlet UILabel *rowLabel;
@property (nonatomic, retain) IBOutlet UILabel *columnLabel;
@property (nonatomic, retain) IBOutlet UIButton *globeImageButton;
@property (nonatomic, retain) IBOutlet UIButton *keefImageButton;
@property (nonatomic, retain) IBOutlet UIButton *startButton;

@property (nonatomic, retain) NSString *imageName;

- (IBAction)rowSliderChanged:(id)sender;
- (IBAction)columnSliderChanges:(id)sender;
- (IBAction)globeButtonPressed:(id)sender;
- (IBAction)keefButtonPressed:(id)sender;
- (IBAction)startButtonPressed:(id)sender;

@end
