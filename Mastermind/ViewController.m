//
//  ViewController.m
//  Mastermind
//
//  Created by manolo on 1/26/15.
//  Copyright (c) 2015 manolosavi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *generatedViews;

@property (weak, nonatomic) IBOutlet UIView *answer1;
@property (weak, nonatomic) IBOutlet UIView *answer2;
@property (weak, nonatomic) IBOutlet UIView *answer3;
@property (weak, nonatomic) IBOutlet UIView *answer4;

@property (weak, nonatomic) IBOutlet UIView *hint1;
@property (weak, nonatomic) IBOutlet UIView *hint2;
@property (weak, nonatomic) IBOutlet UIView *hint3;
@property (weak, nonatomic) IBOutlet UIView *hint4;

@property (weak, nonatomic) IBOutlet UIButton *guess1;
@property (weak, nonatomic) IBOutlet UIButton *guess2;
@property (weak, nonatomic) IBOutlet UIButton *guess3;
@property (weak, nonatomic) IBOutlet UIButton *guess4;

@property (weak, nonatomic) IBOutlet UISegmentedControl *playDebugControl;

@end

@implementation ViewController

int answers[4], guesses[4];
int rightColor, rightPlace, numberGuesses;

- (void)viewDidLoad {
	[super viewDidLoad];

	int radius = 3;
	_answer1.layer.cornerRadius = radius;
	_answer2.layer.cornerRadius = radius;
	_answer3.layer.cornerRadius = radius;
	_answer4.layer.cornerRadius = radius;
	
	_hint1.layer.cornerRadius = radius;
	_hint2.layer.cornerRadius = radius;
	_hint3.layer.cornerRadius = radius;
	_hint4.layer.cornerRadius = radius;
	
	_guess1.layer.cornerRadius = radius;
	_guess2.layer.cornerRadius = radius;
	_guess3.layer.cornerRadius = radius;
	_guess4.layer.cornerRadius = radius;
	
	[self switchMode:0];
	[self restart:nil];
}

- (IBAction)changeButtonColor:(UIButton *)sender {
	[UIView animateWithDuration:.15 animations:^{
		if (sender == _guess1) {
			guesses[0] = (guesses[0]+1)%6;
			[_guess1 setBackgroundColor:[self getColor:guesses[0]]];
		} else if (sender == _guess2) {
			guesses[1] = (guesses[1]+1)%6;
			[_guess2 setBackgroundColor:[self getColor:guesses[1]]];
		} else if (sender == _guess3) {
			guesses[2] = (guesses[2]+1)%6;
			[_guess3 setBackgroundColor:[self getColor:guesses[2]]];
		} else {
			guesses[3] = (guesses[3]+1)%6;
			[_guess4 setBackgroundColor:[self getColor:guesses[3]]];
		}
	}];
}

- (IBAction)restart:(id)sender {
	_playDebugControl.selectedSegmentIndex = 0;
	[self switchMode:_playDebugControl];
	numberGuesses = rightColor = rightPlace = 0;
	for (int i=0; i<4; i++) {
		guesses[i] = 0;
	}
	[self randomize];
	
	[_guess1 setBackgroundColor:[self getColor:guesses[0]]];
	[_guess2 setBackgroundColor:[self getColor:guesses[1]]];
	[_guess3 setBackgroundColor:[self getColor:guesses[2]]];
	[_guess4 setBackgroundColor:[self getColor:guesses[3]]];
	[self colorHintsAnimated:false];
}

- (BOOL)repeatedGuesses {
	for (int i=0; i<4; i++) {
		for (int j=0; j<4; j++) {
			if (i != j && guesses[i] == guesses[j]) {
				return true;
			}
		}
	}
	
	return false;
}

- (IBAction)guess:(id)sender {
	if ([self repeatedGuesses]) {
		[[[UIAlertView alloc] initWithTitle:@"Can't duplicate colors!"
									message:@"All your guesses must be different colors."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	} else {
		numberGuesses++;
		rightColor = rightPlace = 0;
		
		for (int i=0; i<4; i++) {
			if (guesses[i] == answers[i]) {
				rightPlace++;
			}
		}
		
		for (int i=0; i<4; i++) {
			for (int j=0; j<4; j++) {
				if (guesses[i] == answers[j]) {
					rightColor++;
				}
			}
		}
		rightColor -= rightPlace;
		[self colorHintsAnimated:true];
		if (rightPlace == 4) {
			[[[UIAlertView alloc] initWithTitle:@"You Win!"
										message:[NSString stringWithFormat:@"You won in %li tries.", (long)numberGuesses]
									   delegate:self
							  cancelButtonTitle:@"Play again"
							  otherButtonTitles:nil] show];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView.title isEqualToString:@"You Win!"]) {
		[self restart:nil];
	}
}

- (void)colorHintsAnimated:(BOOL)animate {
	double duration = (animate)?.15:0;
	[UIView animateWithDuration:duration animations:^{
		UIView *hints[4];
		hints[0] = _hint1;
		hints[1] = _hint2;
		hints[2] = _hint3;
		hints[3] = _hint4;
		
		for (int i=0; i<rightPlace; i++) {
			[hints[i] setBackgroundColor:[UIColor redColor]];
		}
		
		for (int i=rightPlace; i<rightColor+rightPlace; i++) {
			[hints[i] setBackgroundColor:[UIColor grayColor]];
		}
		
		for (int i=rightColor+rightPlace; i<4; i++) {
			[hints[i] setBackgroundColor:[UIColor whiteColor]];
		}
	}];
}

- (UIColor *)getColor:(int)index {
	switch (index) {
		case 0:
			return [UIColor colorWithHue:3/360.0f saturation:.8f brightness:.94f alpha:1];
		case 1:
			return [UIColor colorWithHue:33/360.0f saturation:.8f brightness:.94f alpha:1];
		case 2:
			return [UIColor colorWithHue:63/360.0f saturation:.8f brightness:.94f alpha:1];
		case 3:
			return [UIColor colorWithHue:133/360.0f saturation:.8f brightness:.94f alpha:1];
		case 4:
			return [UIColor colorWithHue:225/360.0f saturation:.8f brightness:.94f alpha:1];
		default:
			return [UIColor colorWithHue:300/360.0f saturation:.8f brightness:.94f alpha:1];
	}
}

- (void)randomize {
	answers[0] = arc4random_uniform(6);
	
	bool repeat = true;
	while (repeat) {
		answers[1] = arc4random_uniform(6);
		repeat = answers[1]==answers[0];
	}
	
	repeat = true;
	while (repeat) {
		answers[2] = arc4random_uniform(6);
		repeat = false;
		for (int i=0; i<2; i++) {
			if (answers[i] == answers[2]) {
				repeat = true;
			}
		}
	}
	
	repeat = true;
	while (repeat) {
		answers[3] = arc4random_uniform(6);
		repeat = false;
		for (int i=0; i<3; i++) {
			if (answers[i] == answers[3]) {
				repeat = true;
			}
		}
	}
	
	[UIView animateWithDuration:.15 animations:^{
		[_answer1 setBackgroundColor:[self getColor:answers[0]]];
		[_answer2 setBackgroundColor:[self getColor:answers[1]]];
		[_answer3 setBackgroundColor:[self getColor:answers[2]]];
		[_answer4 setBackgroundColor:[self getColor:answers[3]]];
	}];
}

- (IBAction)switchMode:(UISegmentedControl *)sender {
	_generatedViews.hidden = (sender.selectedSegmentIndex == 0);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end