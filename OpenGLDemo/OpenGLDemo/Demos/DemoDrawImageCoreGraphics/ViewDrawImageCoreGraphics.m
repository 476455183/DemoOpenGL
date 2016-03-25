//
//  ViewDrawImageCoreGraphics.m
//  OpenGLDemo
//
//  Created by Chris Hu on 16/3/25.
//  Copyright © 2016年 Chris Hu. All rights reserved.
//

#import "ViewDrawImageCoreGraphics.h"

@implementation ViewDrawImageCoreGraphics {

    CGContextRef context;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 一个不透明的Quartz 2D绘画环境，相当于一个画布
    context = UIGraphicsGetCurrentContext();
    
    [self drawImage:[UIImage imageNamed:@"testImage"]];
}

- (void)drawImage:(UIImage *)image {
    CGImageRef cgImageRef = CGImageRetain(image.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)), cgImageRef);
    
    /*
    UIImage *image = [UIImage imageNamed:@"testImage"];
    [image drawInRect:CGRectMake(60, 70, 20, 20)];//在坐标中画出图片
    //    [image drawAtPoint:CGPointMake(100, 340)];//保持图片大小在point点开始画图片，可以把注释去掉看看
    CGContextDrawImage(_context, CGRectMake(10, 70, 20, 20), image.CGImage);//使用这个使图片上下颠倒了，参考http://blog.csdn.net/koupoo/article/details/8670024
    
    //    CGContextDrawTiledImage(_context, CGRectMake(0, 0, 20, 20), image.CGImage);//平铺图
    */
}

@end
