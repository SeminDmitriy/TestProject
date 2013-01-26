//
//  TapElementView.h
//  TapTapPicture
//
//  Created by Dmitriy Semin on 25.10.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TapElementModel;

@protocol ButtonElementProtocol <NSObject>

@optional

- (void)buttonElementPressed:(TapElementModel *)model;

@end

@interface TapElementView : UIButton <ButtonElementProtocol>
{
    id <ButtonElementProtocol> delegate;
}

@property (weak) id <ButtonElementProtocol> delegate;

@property (nonatomic, strong) TapElementModel *model;

- (void)customizedViewWithModel:(TapElementModel*)currentModel;

@end
