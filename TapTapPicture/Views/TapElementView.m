//
//  TapElementView.m
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import "TapElementView.h"
#import "TapElementModel.h"

#import <QuartzCore/QuartzCore.h>

@implementation TapElementView

@synthesize model = modelSynth;
@synthesize delegate = delegateSynth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)customizedViewWithModel:(TapElementModel*)currentModel
{
    modelSynth = currentModel;
    float lenght      = modelSynth.sizeElement;
    float dHorizontal = modelSynth.horizontalRow;
    float dVertical   = modelSynth.verticalRow;
    [self setFrame:CGRectMake(lenght * dHorizontal,
                              lenght * dVertical, lenght, lenght)];
    
    self.hidden = modelSynth.hiddenElement;
    [self setBackgroundImage:modelSynth.imageElement forState:UIControlStateNormal];
    [self addTarget:self action:@selector(selfButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
}
- (void)selfButtonPress
{
    if ([delegateSynth respondsToSelector:@selector(buttonElementPressed:)])
        [delegateSynth buttonElementPressed:modelSynth];

}
@end
