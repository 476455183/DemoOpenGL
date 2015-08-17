//
//  PaintViaOpenGLESTexture.h
//  OpenGLDemo
//
//  Created by zj－db0465 on 15/8/17.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@protocol TouchDrawViewViaOpenGLESDelegate <NSObject>

- (void)drawCGPointViaOpenGLES:(CGPoint)point inFrame:(CGRect)rect;

- (void)drawCGPointsViaOpenGLES:(NSArray *)points inFrame:(CGRect)rect;

- (void)addImageViaOpenGLES:(UIImage *)image inFrame:(CGRect)rect;

@end

@interface PaintViaOpenGLESTexture : UIView

@property (nonatomic) NSMutableArray *linesCompleted;
@property (nonatomic) Line *currentLine;
@property (nonatomic, weak) id<TouchDrawViewViaOpenGLESDelegate> delegate;

- (void)addImageViaOpenGLES:(UIImage *)image;

@end
