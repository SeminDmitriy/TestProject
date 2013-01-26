//
//  GameViewController.h
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapElementView.h"

@class TapElementModel;

@interface GameViewController : UIViewController <UIGestureRecognizerDelegate, ButtonElementProtocol>
{
    int countElements;
    BOOL newGameCreated;
    
    TapElementModel *previousModelElement;
    
    NSMutableArray  *arrayElementPuzzle;
    NSMutableArray  *arrayElementOriginal;
    NSMutableArray  *arrayAnimationsNewGame;
    
    int currentStepCount;
    BOOL useSwipeRecognizer;
}
@property (nonatomic, strong) IBOutlet UIImageView *imageViewForGame;
@property (nonatomic, strong) IBOutlet UIView *viewForElements;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *startNewGameButton;
@property (nonatomic, strong) IBOutlet UIButton *buttonShowOriginalImage;
@end
