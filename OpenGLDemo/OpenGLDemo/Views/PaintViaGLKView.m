//
//  PaintViaGLKView.m
//  OpenGLDemo
//
//  Created by Chris Hu on 15/8/25.
//  Copyright (c) 2015年 Chris Hu. All rights reserved.
//

#import "PaintViaGLKView.h"

#define Middle_CGPoint(start, end) CGPointMake(start.x + (end.x - start.x) / 2, start.y + (end.y - start.y) / 2)
#define Distance_CGPoints(start, end) sqrt((end.x-start.x)*(end.x-start.x) + (end.y - start.y) * (end.y - start.y))

typedef NS_ENUM(NSInteger, touchType) {
    touchesBegan = 0,
    touchesMoved,
    touchesEnded,
};

@interface PaintViaGLKView ()

@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) NSMutableArray *points;

@property (nonatomic) NSMutableArray *tmpTouchPoints; // 计算贝塞尔曲线的时候使用.

@end

@implementation PaintViaGLKView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:YES];
        [self becomeFirstResponder];
        
        _points = [[NSMutableArray alloc] init];
        _tmpTouchPoints = [[NSMutableArray alloc] init];
        _previousPoint = CGPointZero;
    }
    
    return self;
}

- (void)drawFrom:(CGPoint)start to:(CGPoint)end touchType:(NSInteger)touchType {
    if (CGPointEqualToPoint(start, end) || touchType == touchesBegan || touchType == touchesEnded) {
        if ([self.delegate respondsToSelector:@selector(drawCGPointViaGLKView:inFrame:)]) {
            [self.delegate drawCGPointViaGLKView:end inFrame:self.frame];
            return;
        }
    }
    
    //    [_points insertObject:[NSValue valueWithCGPoint:start] atIndex:0];
    //    [self addCGPointsFrom:start to:end];
    //    [_points addObject:[NSValue valueWithCGPoint:end]];
    
    [self addCGPointsViaBezeier:start to:end];
    
    NSLog(@"_points : %@", _points);
    
    if ([self.delegate respondsToSelector:@selector(drawCGPointsViaGLKView:inFrame:)]) {
        [self.delegate drawCGPointsViaGLKView:_points inFrame:self.frame];
    }
}

- (void)addCGPointsFrom:(CGPoint)start to:(CGPoint)end {
    NSLog(@"start : %.1f-%.1f", start.x, start.y);
    NSLog(@"end : %.1f-%.1f", end.x, end.y);
    // line width 为 10
    if (fabs(end.x - start.x) > 10 || fabs(end.y - start.y) > 10) {
        CGPoint middle = Middle_CGPoint(start, end);
        [self addCGPointsFrom:start to:middle];
        [_points addObject:[NSValue valueWithCGPoint:middle]];
        [self addCGPointsFrom:middle to:end];
    }
}

- (void)addCGPointsViaBezeier:(CGPoint)start to:(CGPoint)end {
    CGPoint p1, p2, p3;
    if (_tmpTouchPoints.count > 2) {
        p1 = Middle_CGPoint([_tmpTouchPoints[_tmpTouchPoints.count - 3] CGPointValue], start);
        p2 = start;
        p3 = Middle_CGPoint(start, end);
    } else {
        p1 = start;
        p3 = Middle_CGPoint(start, end);
        p2 = Middle_CGPoint(start, p3);
    }
    
    CGFloat tValue = 0.5 / Distance_CGPoints(p1, p3);
    if (tValue > 0.5) {
        tValue = 0.5;
    }
    for (CGFloat t=0; t<1; t+=tValue) {
        CGFloat x = (1 - t) * (1 - t) * p1.x + 2 * t * (1 - t) * p2.x + t * t * p3.x;
        CGFloat y = (1 - t) * (1 - t) * p1.y + 2 * t * (1 - t) * p2.y + t * t * p3.y;
        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - screen touch operations

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    [_points removeAllObjects];
    for (UITouch *t in touches) {
        // 获取该touch的point
        CGPoint p = [t locationInView:self];
        if (CGPointEqualToPoint(_previousPoint, CGPointZero)) {
            _previousPoint = p;
        }
        [_tmpTouchPoints addObject:[NSValue valueWithCGPoint:p]];
        [self drawFrom:_previousPoint to:p touchType:touchesBegan];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesMoved");
    [_points removeAllObjects];
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [_tmpTouchPoints addObject:[NSValue valueWithCGPoint:p]];
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
        [_tmpTouchPoints removeAllObjects];
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
