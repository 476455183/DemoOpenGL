//
//  DemoDrawImageCoreGraphics.m
//  OpenGLDemo
//
//  Created by Chris Hu on 16/1/10.
//  Copyright © 2016年 Chris Hu. All rights reserved.
//

#import "DemoDrawImageCoreGraphics.h"
#import "ViewDrawImageCoreGraphics.h"
#import "ViewDrawPathCoreGraphics.h"

@interface DemoDrawImageCoreGraphics ()

@end

@implementation DemoDrawImageCoreGraphics

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self drawImageCoreGraphics];
    
    [self drawPathCoreGraphics];
}


- (void)drawImageCoreGraphics {
    UILabel *lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, CGRectGetWidth(self.view.frame) - 20, 30)];
    lbOriginalImage.text = @"Draw Image via CoreGraphics";
    lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbOriginalImage];
    
    // 使用Core Graphics绘制图片
    ViewDrawImageCoreGraphics *drawImage = [[ViewDrawImageCoreGraphics alloc] initWithFrame:CGRectMake(10, 100, CGRectGetWidth(self.view.frame) - 20, 200)];
    [self.view addSubview:drawImage];
}

- (void)drawPathCoreGraphics {
    UILabel *lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, CGRectGetWidth(self.view.frame) - 20, 30)];
    lbOriginalImage.text = @"Draw Path via CoreGraphics";
    lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbOriginalImage];
    
    // 使用Core Graphics绘制路径
    ViewDrawPathCoreGraphics *drawPath = [[ViewDrawPathCoreGraphics alloc] initWithFrame:CGRectMake(10, 350, CGRectGetWidth(self.view.frame) - 20, 200)];
    [self.view addSubview:drawPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
