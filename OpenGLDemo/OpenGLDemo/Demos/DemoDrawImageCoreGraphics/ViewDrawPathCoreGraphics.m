//
//  ViewDrawPathCoreGraphics.m
//  OpenGLDemo
//
//  Created by Chris Hu on 16/3/25.
//  Copyright © 2016年 Chris Hu. All rights reserved.
//

#import "ViewDrawPathCoreGraphics.h"

#define PI 3.14159265358979323846
#define DEGREES_TO_RADIANS(degrees) ((PI * degrees)/ 180)

@implementation ViewDrawPathCoreGraphics {

    CGContextRef context;
    
    NSMutableArray *points;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        points = [[NSMutableArray alloc] init];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    context = UIGraphicsGetCurrentContext();
    
    [self drawGraphs];
    
    [self drawTouchPoints];
}

#pragma mark - drawGraphs
- (void)drawGraphs {
    [self drawCircle];
    [self drawCircleFill];
    
    [self drawLine];
    
    [self drawARC];
    
    [self drawRects];
    
    [self drawBezierPath];
}

- (void)drawCircle {
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1); // 填充颜色
    CGContextSetLineWidth(context, 2.5);
    CGContextAddArc(context, 20, 20, 15, 0, 2 * PI, 0);
    CGContextDrawPath(context, kCGPathStroke); // 绘制路径
}

- (void)drawCircleFill {
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddArc(context, 60, 20, 20, 0, 2 * PI, 0);
    CGContextDrawPath(context, kCGPathFill); // 绘制填充
}

- (void)drawLine {
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    
    // 根据坐标绘制路径
    CGPoint aPoints[2];
    aPoints[0] = CGPointMake(100, 20);
    aPoints[1] = CGPointMake(130, 20);
    CGContextAddLines(context, aPoints, 2);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawARC {
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextMoveToPoint(context, 20, 60); // 设置开始坐标点
    // 即从三个点绘制圆弧：(20,60)->(30,50)->(40,60)
    // 半径为20.
    CGContextAddArcToPoint(context, 30, 50, 40, 60, 20);
    CGContextStrokePath(context); // 绘制路径, 也可采用下边方式
    // CGContextDrawPath(context, kCGPathStroke);
    
    CGContextMoveToPoint(context, 60, 60);
    CGContextAddArcToPoint(context, 70, 50, 80, 60, 20);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 30, 80);
    CGContextAddArcToPoint(context, 50, 90, 70, 80, 40);
    CGContextStrokePath(context);
}

- (void)drawRects {
    CGContextStrokeRect(context,CGRectMake(100, 120, 10, 10));//画方框
    CGContextFillRect(context,CGRectMake(120, 120, 10, 10));//填充框
    //矩形，并填弃颜色
    CGContextSetLineWidth(context, 2.0);//线的宽度
    UIColor *aColor = [UIColor blueColor];//blue蓝色
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    aColor = [UIColor yellowColor];
    CGContextSetStrokeColorWithColor(context, aColor.CGColor);//线框颜色
    CGContextAddRect(context,CGRectMake(140, 120, 60, 30));//画方框
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    
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
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 220, 90);
    CGContextAddLineToPoint(context, 240, 90);
    CGContextAddLineToPoint(context, 240, 110);
    CGContextAddLineToPoint(context, 220, 110);
    CGContextClip(context);//context裁剪路径,后续操作的路径
    //CGContextDrawLinearGradient(CGContextRef context,CGGradientRef gradient, CGPoint startPoint, CGPoint endPoint,CGGradientDrawingOptions options)
    //gradient渐变颜色,startPoint开始渐变的起始位置,endPoint结束坐标,options开始坐标之前or开始之后开始渐变
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                (220,90) ,CGPointMake(240,110),
                                kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);// 恢复到之前的context
    
    //再写一个看看效果
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, 260, 90);
    CGContextAddLineToPoint(context, 280, 90);
    CGContextAddLineToPoint(context, 280, 100);
    CGContextAddLineToPoint(context, 260, 100);
    CGContextClip(context);//裁剪路径
    //说白了，开始坐标和结束坐标是控制渐变的方向和形状
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                (260, 90) ,CGPointMake(260, 100),
                                kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);// 恢复到之前的context

    
    
    //下面再看一个颜色渐变的圆
    CGContextDrawRadialGradient(context, gradient, CGPointMake(300, 100), 0.0, CGPointMake(300, 100), 10, kCGGradientDrawsBeforeStartLocation);
    
    /*画扇形和椭圆*/
    //画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
    aColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    //以10为半径围绕圆心画指定角度扇形
    CGContextMoveToPoint(context, 160, 180);
    CGContextAddArc(context, 160, 180, 30,  -60 * PI / 180, -120 * PI / 180, 1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
    
    //画椭圆
    CGContextAddEllipseInRect(context, CGRectMake(160, 180, 20, 8)); //椭圆
    CGContextDrawPath(context, kCGPathFillStroke);
    
    /*画三角形*/
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(100, 220);//坐标1
    sPoints[1] =CGPointMake(130, 220);//坐标2
    sPoints[2] =CGPointMake(130, 160);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    /*画圆角矩形*/
    float fw = 180;
    float fh = 280;
    
    CGContextMoveToPoint(context, fw, fh-20);  // 开始坐标右边开始
    CGContextAddArcToPoint(context, fw, fh, fw-20, fh, 10);  // 右下角角度
    CGContextAddArcToPoint(context, 120, fh, 120, fh-20, 10); // 左下角角度
    CGContextAddArcToPoint(context, 120, 250, fw-20, 250, 10); // 左上角
    CGContextAddArcToPoint(context, fw, 250, fw, fh-20, 10); // 右上角
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    /*画贝塞尔曲线*/
    //二次曲线
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextMoveToPoint(context, 120, 60);//设置Path的起点
    CGContextAddQuadCurveToPoint(context,190, 110, 120, 200);//设置贝塞尔曲线的控制点坐标和终点坐标
    CGContextStrokePath(context);
    //三次曲线函数
    CGContextMoveToPoint(context, 10, 100);//设置Path的起点
    CGContextAddCurveToPoint(context, 100, 50, 200, 200, 300, 100);//设置贝塞尔曲线的控制点坐标和控制点坐标终点坐标
    CGContextStrokePath(context);
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

- (void)drawTouchPoints {
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextSetLineWidth(context, 10);
    CGContextSetLineCap(context, kCGLineCapRound);
    for (id rawPoint in points) {
        CGPoint p =[rawPoint CGPointValue];
        CGContextMoveToPoint(context, p.x, p.y);
        CGContextAddLineToPoint(context, p.x, p.y);
        CGContextStrokePath(context);
    }
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        // 获取该touch的point
        CGPoint p = [t locationInView:self];
        [points addObject:[NSValue valueWithCGPoint:p]];
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        [points addObject:[NSValue valueWithCGPoint:p]];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setNeedsDisplay];
}

#pragma mark - motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [points removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

@end
