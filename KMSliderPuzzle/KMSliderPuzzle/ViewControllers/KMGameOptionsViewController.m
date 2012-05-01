//
//  KMGameOptionsViewController.m
//  KMSliderPuzzle
//
//  Created by Keith Moon on 01/05/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#import "KMGameOptionsViewController.h"
#import "KMPuzzleViewController.h"
#import "KMPuzzleGame.h"

#define kImageNameGlobe     @"Globe.png"
#define kImageNameKeef      @"keefmoon.png"

@interface KMGameOptionsViewController ()

@end

@implementation KMGameOptionsViewController

@synthesize rowSlider;
@synthesize columnSlider;
@synthesize rowLabel;
@synthesize columnLabel;
@synthesize globeImageButton;
@synthesize keefImageButton;
@synthesize startButton;
@synthesize imageName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Keith Moon's Slider Puzzle";
    
    // Default image selected
    self.imageName = kImageNameGlobe;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.rowSlider = nil;
    self.columnSlider = nil;
    self.rowLabel = nil;
    self.columnLabel = nil;
    self.globeImageButton = nil;
    self.keefImageButton = nil;
    self.startButton = nil;
}

- (void)dealloc
{
    self.rowSlider = nil;
    self.columnSlider = nil;
    self.rowLabel = nil;
    self.columnLabel = nil;
    self.globeImageButton = nil;
    self.keefImageButton = nil;
    self.startButton = nil;
    self.imageName = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction Methods

- (IBAction)rowSliderChanged:(id)sender
{
    self.rowSlider.value = round(self.rowSlider.value);
    self.rowLabel.text = [NSString stringWithFormat:@"%.0f", self.rowSlider.value];
}

- (IBAction)columnSliderChanges:(id)sender
{
    self.columnSlider.value = round(self.columnSlider.value);
    self.columnLabel.text = [NSString stringWithFormat:@"%.0f", self.columnSlider.value];
}

- (IBAction)globeButtonPressed:(id)sender
{
    self.imageName = kImageNameGlobe;
    self.globeImageButton.alpha = 1.0f;
    self.keefImageButton.alpha = 0.7f;
}

- (IBAction)keefButtonPressed:(id)sender
{
    self.imageName = kImageNameKeef;
    self.keefImageButton.alpha = 1.0f;
    self.globeImageButton.alpha = 0.7f;
}

- (IBAction)startButtonPressed:(id)sender
{
    // Future improvement:
    // Save completed games and select them from a history list to watch a replay.
    
    KMPuzzleGame *newGame = [[KMPuzzleGame alloc] initWithImage:[UIImage imageNamed:self.imageName] 
                                                   numberOfRows:self.rowSlider.value 
                                                     andColumns:self.columnSlider.value];
    
    KMPuzzleViewController *puzzleVC = [[KMPuzzleViewController alloc] initWithGame:newGame];
    [newGame release];
    
    [self.navigationController pushViewController:puzzleVC animated:YES];
    [puzzleVC release];
}

@end
