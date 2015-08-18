//
//  TouchDrawViewViaOpenGLES.m
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/8/6.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import "TouchDrawViewViaOpenGLES.h"

typedef NS_ENUM(NSInteger, touchType) {
    touchesBegan = 0,
    touchesMoved,
    touchesEnded,
};

@interface TouchDrawViewViaOpenGLES ()

@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) NSMutableArray *points;

@end

@implementation TouchDrawViewViaOpenGLES

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:YES];
        [self becomeFirstResponder];

        _points = [[NSMutableArray alloc] init];
        _previousPoint = CGPointZero;
    }

    return self;
}

#pragma mark - addImageViaOpenGLES

- (void)addImageViaOpenGLES:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(addImageViaOpenGLES:inFrame:)]) {
        [self.delegate addImageViaOpenGLES:image inFrame:self.frame];
    }
}

- (void)drawFrom:(CGPoint)start to:(CGPoint)end touchType:(NSInteger)touchType {
    if (CGPointEqualToPoint(start, end) || touchType == touchesBegan || touchType == touchesEnded) {
        if ([self.delegate respondsToSelector:@selector(drawCGPointViaOpenGLES:inFrame:)]) {
            [self.delegate drawCGPointViaOpenGLES:end inFrame:self.frame];
            return;
        }
    }

    [_points insertObject:[NSValue valueWithCGPoint:start] atIndex:0];
    [self addCGPointsFrom:start to:end];
    [_points addObject:[NSValue valueWithCGPoint:end]];
    NSLog(@"_points : %@", _points);
//        if ([self.delegate respondsToSelector:@selector(drawCGPointViaOpenGLES:inFrame:)]) {
//            for (id rawPoint in _points) {
//                [self.delegate drawCGPointViaOpenGLES:[rawPoint CGPointValue] inFrame:self.frame];
//            }
//        }

    if ([self.delegate respondsToSelector:@selector(drawCGPointsViaOpenGLES:inFrame:)]) {
        [self.delegate drawCGPointsViaOpenGLES:_points inFrame:self.frame];
    }
}

- (void)addCGPointsFrom:(CGPoint)start to:(CGPoint)end {
    NSLog(@"start : %.1f-%.1f", start.x, start.y);
    NSLog(@"end : %.1f-%.1f", end.x, end.y);
    // line width 为 10
    if (fabs(end.x - start.x) > 10 || fabs(end.y - start.y) > 10) {
        CGPoint middle = {
            start.x + (end.x - start.x) / 2,
            start.y + (end.y - start.y) / 2};
        [self addCGPointsFrom:start to:middle];
        [_points addObject:[NSValue valueWithCGPoint:middle]];
        [self addCGPointsFrom:middle to:end];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - screen touch operations

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    for (UITouch *t in touches) {
        // 获取该touch的point
        CGPoint p = [t locationInView:self];
        if (CGPointEqualToPoint(_previousPoint, CGPointZero)) {
            _previousPoint = p;
        }
        [self drawFrom:_previousPoint to:p touchType:touchesBegan];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesMoved");
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [self drawFrom:_previousPoint to:p touchType:touchesMoved];
        _previousPoint = p;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [self drawFrom:_previousPoint to:p touchType:touchesEnded];
        _previousPoint = CGPointZero;
        [_points removeAllObjects];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}

#pragma mark - motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionBegan");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionEnded");
    if (motion == UIEventSubtypeMotionShake) {
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionCancelled");
}

@end
