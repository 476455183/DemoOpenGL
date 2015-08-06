//
//  Line.h
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/8/6.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Line : NSObject

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;
@property (nonatomic) UIColor *color;

@end
