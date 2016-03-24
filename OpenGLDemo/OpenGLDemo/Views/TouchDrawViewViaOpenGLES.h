//
//  TouchDrawViewViaOpenGLES.h
//  OpenGLDemo
//
//  Created by Chris Hu on 15/8/6.
//  Copyright (c) 2015年 Chris Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchDrawViewViaOpenGLESDelegate <NSObject>

- (void)preparePaintOpenGLES;

- (void)drawCGPointViaOpenGLES:(CGPoint)point inFrame:(CGRect)rect;

- (void)drawCGPointsViaOpenGLES:(NSArray *)points inFrame:(CGRect)rect;

- (void)addImageViaOpenGLES:(UIImage *)image inFrame:(CGRect)rect;

@end

@interface TouchDrawViewViaOpenGLES : UIView

@property (nonatomic, weak) id<TouchDrawViewViaOpenGLESDelegate> delegate;

@end
