//
//  PaintViaGLKView.h
//  OpenGLDemo
//
//  Created by Chris Hu on 15/8/25.
//  Copyright (c) 2015年 Chris Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaintViaGLKViewDelegate <NSObject>

- (void)preparePaintGLKView:(CGRect)rect;

- (void)drawCGPointViaGLKView:(CGPoint)point inFrame:(CGRect)rect;

- (void)drawCGPointsViaGLKView:(NSArray *)points inFrame:(CGRect)rect;

- (void)addImageViaGLKView:(UIImage *)image inFrame:(CGRect)rect;

@end

@interface PaintViaGLKView : UIView

@property (nonatomic, weak) id<PaintViaGLKViewDelegate> delegate;

@end
