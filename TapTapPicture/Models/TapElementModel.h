//
//  TapElementModel.h
//  TapTapPicture
//
//  Created by Dmitriy Semin on 27.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TapElementModel : NSObject

@property (nonatomic, assign) int     horizontalRow;
@property (nonatomic, assign) int     verticalRow;
@property (nonatomic, assign) float   sizeElement;
@property (nonatomic, assign) int     indexElement;
@property (nonatomic, assign) CGPoint centerElementView;
@property (nonatomic, assign) BOOL    hiddenElement;
@property (nonatomic, assign) int     pathToHiddenElement;
@property (nonatomic, strong) UIImage *imageElement;
@end
