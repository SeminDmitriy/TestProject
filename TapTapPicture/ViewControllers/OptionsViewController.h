//
//  OptionsViewController.h
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *fieldCountElements;
@property (nonatomic, strong) IBOutlet UITextField *fieldCountMoves;
@property (nonatomic, strong) IBOutlet UIStepper *stepperCountElements;
@property (nonatomic, strong) IBOutlet UIStepper *stepperCountMoves;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewPictureForGame;
- (IBAction)stepperElementsValueChanged:(id)sender;
- (IBAction)stepperMovesValueChanged:(id)sender;
@end
