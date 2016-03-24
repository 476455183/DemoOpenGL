//
//  TouchDrawViewViaCoreGraphics.m
//  OpenGLDemo
//
//  Created by Chris Hu on 15/8/6.
//  Copyright (c) 2015年 Chris Hu. All rights reserved.
//

#import "TouchDrawViewViaCoreGraphics.h"

#define PI 3.14159265358979323846
#define DEGREES_TO_RADIANS(degrees) ((PI * degrees)/ 180)

@interface TouchDrawViewViaCoreGraphics ()

@property (nonatomic) CGContextRef context;

@property (nonatomic) NSMutableArray *points;

@end

@implementation TouchDrawViewViaCoreGraphics

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:YES];
        [self becomeFirstResponder];
        
        _points = [[NSMutableArray alloc] init];
    }

    return self;
}

// 每次屏幕需要刷新的时候调用, setNeedsDisplay会调用drawRect.
- (void)drawRect:(CGRect)rect {
    //一个不透明类型的Quartz 2D绘画环境, 相当于一个画布.
    _context = UIGraphicsGetCurrentContext();

    [self drawImage:[UIImage imageNamed:@"testImage"]];
    [self drawCGPoint];
    [self demosCGDraw];
    [self drawBezierPath];
}

- (void)drawImage:(UIImage *)image {
    CGImageRef cgImageRef = CGImageRetain([image CGImage]);
    CGContextDrawImage(_context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), cgImageRef);
}

- (void)drawCGPoint {
    CGContextSetLineWidth(_context, 10.0);
    CGContextSetLineCap(_context, kCGLineCapRound);
    CGContextSetRGBStrokeColor(_context, 1, 0, 1, 1);
    for (id rawPoint in _points) {
        CGPoint p = [rawPoint CGPointValue];
        CGContextMoveToPoint(_context, p.x, p.y);
        CGContextAddLineToPoint(_context, p.x, p.y);
        CGContextStrokePath(_context);
    }
}

- (void)demosCGDraw {
    CGContextSetRGBStrokeColor(_context, 1.0, 0, 0, 1.0); // 设置填充颜色
    CGContextSetLineWidth(_context, 5.0);
    CGContextAddArc(_context, 20, 20, 15, 0, 2*PI, 0); // 画一个圆
    CGContextDrawPath(_context, kCGPathStroke); // 绘制路径

    UIColor *fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    CGContextSetFillColorWithColor(_context, fillColor.CGColor);
    CGContextAddArc(_context, 60, 20, 20, 0, 2*PI, 0);
    CGContextDrawPath(_context, kCGPathFill); // 绘制填充
    
    CGContextAddArc(_context, 120, 20, 20, 0, 2*PI, 0);
    CGContextDrawPath(_context, kCGPathFillStroke); // 绘制路径和填充
    
    CGPoint aPoints[2];//坐标点
    aPoints[0] =CGPointMake(100, 80);//坐标1
    aPoints[1] =CGPointMake(130, 80);//坐标2
    //CGContextAddLines(CGContextRef c, const CGPoint points[],size_t count)
    //points[]坐标数组，和count大小
    CGContextAddLines(_context, aPoints, 2);//添加直线
    CGContextDrawPath(_context, kCGPathStroke); //根据坐标绘制路径
    
    //画笑脸弧线
    //左
    CGContextSetRGBStrokeColor(_context, 0, 0, 1, 1);//改变画笔颜色
    CGContextMoveToPoint(_context, 140, 80);//开始坐标p1
    //CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1,CGFloat x2, CGFloat y2, CGFloat radius)
    //x1,y1跟p1形成一条线的坐标p2，x2,y2结束坐标跟p3形成一条线的p3,radius半径,注意, 需要算好半径的长度,
    CGContextAddArcToPoint(_context, 148, 68, 156, 80, 10);
    CGContextStrokePath(_context);//绘画路径

    //右
    CGContextMoveToPoint(_context, 160, 80);//开始坐标p1
    //CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1,CGFloat x2, CGFloat y2, CGFloat radius)
    //x1,y1跟p1形成一条线的坐标p2，x2,y2结束坐标跟p3形成一条线的p3,radius半径,注意, 需要算好半径的长度,
    CGContextAddArcToPoint(_context, 168, 68, 176, 80, 10);
    CGContextStrokePath(_context);//绘画路径
    
    //右
    CGContextMoveToPoint(_context, 150, 90);//开始坐标p1
    //CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1,CGFloat x2, CGFloat y2, CGFloat radius)
    //x1,y1跟p1形成一条线的坐标p2，x2,y2结束坐标跟p3形成一条线的p3,radius半径,注意, 需要算好半径的长度,
    CGContextAddArcToPoint(_context, 158, 102, 166, 90, 10);
    CGContextStrokePath(_context);//绘画路径
    //注，如果还是没弄明白怎么回事，请参考：http://donbe.blog.163.com/blog/static/138048021201052093633776/
    
    /*画矩形*/
    CGContextStrokeRect(_context,CGRectMake(100, 120, 10, 10));//画方框
    CGContextFillRect(_context,CGRectMake(120, 120, 10, 10));//填充框
    //矩形，并填弃颜色
    CGContextSetLineWidth(_context, 2.0);//线的宽度
    UIColor *aColor = [UIColor blueColor];//blue蓝色
    CGContextSetFillColorWithColor(_context, aColor.CGColor);//填充颜色
    aColor = [UIColor yellowColor];
    CGContextSetStrokeColorWithColor(_context, aColor.CGColor);//线框颜色
    CGContextAddRect(_context,CGRectMake(140, 120, 60, 30));//画方框
    CGContextDrawPath(_context, kCGPathFillStroke);//绘画路径
    
    //矩形，并填弃渐变颜色
    //关于颜色参考http://blog.sina.com.cn/s/blog_6ec3c9ce01015v3c.html
    //http://blog.csdn.net/reylen/article/details/8622932
    //第一种填充方式，第一种方式必须导入类库quartcore并#import <QuartzCore/QuartzCore.h>，这个就不属于在context上画，而是将层插入到view层上面。那么这里就设计到Quartz Core 图层编程了。
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.frame = CGRectMake(240, 120, 60, 30);
    gradient1.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor,
                        (id)[UIColor grayColor].CGColor,
                        (id)[UIColor blackColor].CGColor,
                        (id)[UIColor yellowColor].CGColor,
                        (id)[UIColor blueColor].CGColor,
                        (id)[UIColor redColor].CGColor,
                        (id)[UIColor greenColor].CGColor,
                        (id)[UIColor orangeColor].CGColor,
                        (id)[UIColor brownColor].CGColor,nil];
    [self.layer insertSublayer:gradient1 atIndex:0];
    //第二种填充方式
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] =
    {
        1,1,1, 1.00,
        1,1,0, 1.00,
        1,0,0, 1.00,
        1,0,1, 1.00,
        0,1,1, 1.00,
        0,1,0, 1.00,
        0,0,1, 1.00,
        0,0,0, 1.00,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents
    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));//形成梯形，渐变的效果
    CGColorSpaceRelease(rgb);
    //画线形成一个矩形
    //CGContextSaveGState与CGContextRestoreGState的作用
    /*
     CGContextSaveGState函数的作用是将当前图形状态推入堆栈。之后，您对图形状态所做的修改会影响随后的描画操作，但不影响存储在堆栈中的拷贝。在修改完成后，您可以通过CGContextRestoreGState函数把堆栈顶部的状态弹出，返回到之前的图形状态。这种推入和弹出的方式是回到之前图形状态的快速方法，避免逐个撤消所有的状态修改；这也是将某些状态（比如裁剪路径）恢复到原有设置的唯一方式。
     */
    CGContextSaveGState(_context);
    CGContextMoveToPoint(_context, 220, 90);
    CGContextAddLineToPoint(_context, 240, 90);
    CGContextAddLineToPoint(_context, 240, 110);
    CGContextAddLineToPoint(_context, 220, 110);
    CGContextClip(_context);//context裁剪路径,后续操作的路径
    //CGContextDrawLinearGradient(CGContextRef context,CGGradientRef gradient, CGPoint startPoint, CGPoint endPoint,CGGradientDrawingOptions options)
    //gradient渐变颜色,startPoint开始渐变的起始位置,endPoint结束坐标,options开始坐标之前or开始之后开始渐变
    CGContextDrawLinearGradient(_context, gradient,CGPointMake
                                (220,90) ,CGPointMake(240,110),
                                kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(_context);// 恢复到之前的context
    
    //再写一个看看效果
    CGContextSaveGState(_context);
    CGContextMoveToPoint(_context, 260, 90);
    CGContextAddLineToPoint(_context, 280, 90);
    CGContextAddLineToPoint(_context, 280, 100);
    CGContextAddLineToPoint(_context, 260, 100);
    CGContextClip(_context);//裁剪路径
    //说白了，开始坐标和结束坐标是控制渐变的方向和形状
    CGContextDrawLinearGradient(_context, gradient,CGPointMake
                                (260, 90) ,CGPointMake(260, 100),
                                kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(_context);// 恢复到之前的context
    
    //下面再看一个颜色渐变的圆
    CGContextDrawRadialGradient(_context, gradient, CGPointMake(300, 100), 0.0, CGPointMake(300, 100), 10, kCGGradientDrawsBeforeStartLocation);
    
    /*画扇形和椭圆*/
    //画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
    aColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(_context, aColor.CGColor);//填充颜色
    //以10为半径围绕圆心画指定角度扇形
    CGContextMoveToPoint(_context, 160, 180);
    CGContextAddArc(_context, 160, 180, 30,  -60 * PI / 180, -120 * PI / 180, 1);
    CGContextClosePath(_context);
    CGContextDrawPath(_context, kCGPathFillStroke); //绘制路径
    
    //画椭圆
    CGContextAddEllipseInRect(_context, CGRectMake(160, 180, 20, 8)); //椭圆
    CGContextDrawPath(_context, kCGPathFillStroke);
    
    /*画三角形*/
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(100, 220);//坐标1
    sPoints[1] =CGPointMake(130, 220);//坐标2
    sPoints[2] =CGPointMake(130, 160);//坐标3
    CGContextAddLines(_context, sPoints, 3);//添加线
    CGContextClosePath(_context);//封起来
    CGContextDrawPath(_context, kCGPathFillStroke); //根据坐标绘制路径
    
    /*画圆角矩形*/
    float fw = 180;
    float fh = 280;
    
    CGContextMoveToPoint(_context, fw, fh-20);  // 开始坐标右边开始
    CGContextAddArcToPoint(_context, fw, fh, fw-20, fh, 10);  // 右下角角度
    CGContextAddArcToPoint(_context, 120, fh, 120, fh-20, 10); // 左下角角度
    CGContextAddArcToPoint(_context, 120, 250, fw-20, 250, 10); // 左上角
    CGContextAddArcToPoint(_context, fw, 250, fw, fh-20, 10); // 右上角
    CGContextClosePath(_context);
    CGContextDrawPath(_context, kCGPathFillStroke); //根据坐标绘制路径
    
    /*画贝塞尔曲线*/
    //二次曲线
    CGContextSetRGBStrokeColor(_context, 1.0, 0.0, 0.0, 1.0);
    CGContextMoveToPoint(_context, 120, 60);//设置Path的起点
    CGContextAddQuadCurveToPoint(_context,190, 110, 120, 200);//设置贝塞尔曲线的控制点坐标和终点坐标
    CGContextStrokePath(_context);
    //三次曲线函数
    CGContextMoveToPoint(_context, 10, 100);//设置Path的起点
    CGContextAddCurveToPoint(_context, 100, 50, 200, 200, 300, 100);//设置贝塞尔曲线的控制点坐标和控制点坐标终点坐标
    CGContextStrokePath(_context);
    
    /*图片*/
    UIImage *image = [UIImage imageNamed:@"testImage"];
    [image drawInRect:CGRectMake(60, 70, 20, 20)];//在坐标中画出图片
    //    [image drawAtPoint:CGPointMake(100, 340)];//保持图片大小在point点开始画图片，可以把注释去掉看看
    CGContextDrawImage(_context, CGRectMake(10, 70, 20, 20), image.CGImage);//使用这个使图片上下颠倒了，参考http://blog.csdn.net/koupoo/article/details/8670024
    
    //    CGContextDrawTiledImage(_context, CGRectMake(0, 0, 20, 20), image.CGImage);//平铺图
}

- (void)drawBezierPath {
    UIColor *color = [UIColor redColor];
    [color set];  //设置线条颜色
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 5.0;
    aPath.lineCapStyle = kCGLineCapRound;   //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
    
    //设置起始点
    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
    
    //创建line, line的起点是之前的一个点, 终点即指定的点.
    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
    [aPath addLineToPoint:CGPointMake(160.0, 140.0)];
    [aPath addLineToPoint:CGPointMake(40.0, 140.0)];
    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
    //第五条线通过调用closePath方法得到的, 连接起始点与终点.
    [aPath closePath];
    
    [aPath stroke]; //绘制图形
//    [aPath fill]; //填充图形
    
    //绘制矩形
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRect:CGRectMake(10, 10, 100, 100)];
    bPath.lineWidth = 5.0;
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    [bPath stroke];

    //绘制圆形
    UIBezierPath *cPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(200, 10, 100, 100)];
    cPath.lineWidth = 5.0;
    cPath.lineCapStyle = kCGLineCapRound;
    cPath.lineJoinStyle = kCGLineCapRound;
    [cPath stroke];
    
    //绘制一段弧线
    UIBezierPath *dPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(150, 100) radius:75 startAngle:0 endAngle:DEGREES_TO_RADIANS(135) clockwise:YES];
    dPath.lineWidth = 5.0;
    dPath.lineCapStyle = kCGLineCapRound;
    dPath.lineJoinStyle = kCGLineCapRound;
    [dPath stroke];
    
    [[UIColor blueColor] set];
    
    //二次曲线
    UIBezierPath *ePath = [UIBezierPath bezierPath];
    ePath.lineWidth = 5.0;
    ePath.lineCapStyle = kCGLineCapRound;
    ePath.lineJoinStyle = kCGLineCapRound;
    [ePath moveToPoint:CGPointMake(20, 100)];
    [ePath addQuadCurveToPoint:CGPointMake(120, 100) controlPoint:CGPointMake(70, 0)];
    [ePath stroke];
    
    //三次曲线
    UIBezierPath *fPath = [UIBezierPath bezierPath];
    fPath.lineWidth = 5.0;
    fPath.lineCapStyle = kCGLineCapRound;
    fPath.lineJoinStyle = kCGLineCapRound;
    [fPath moveToPoint:CGPointMake(100, 100)];
    [fPath addCurveToPoint:CGPointMake(300, 100) controlPoint1:CGPointMake(150, 50) controlPoint2:CGPointMake(250, 150)];
    [fPath stroke];
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
        [_points addObject:[NSValue valueWithCGPoint:p]];
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesMoved");
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [_points addObject:[NSValue valueWithCGPoint:p]];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
    [self setNeedsDisplay];
}

#pragma mark - motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionBegan");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionEnded");
    if (motion == UIEventSubtypeMotionShake) {
        [_points removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionCancelled");
}

@end
