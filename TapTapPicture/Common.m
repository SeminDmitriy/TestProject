//
//  Common.m
//  TapTapPicture
//
//  Created by Dmitriy Semin on 02.11.12.
//  Copyright (c) 2012 Dmitriy Semin. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (NSString *)pathToDocumentsDirectory
{
    NSString      *path        = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    
    path = [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]];
    
    return path;
}
@end
