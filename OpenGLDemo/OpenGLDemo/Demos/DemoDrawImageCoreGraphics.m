//
//  DemoDrawImageCoreGraphics.m
//  OpenGLDemo
//
//  Created by Chris Hu on 16/1/10.
//  Copyright © 2016年 Chris Hu. All rights reserved.
//

#import "DemoDrawImageCoreGraphics.h"

#import "TouchDrawViewViaCoreGraphics.h"

@interface DemoDrawImageCoreGraphics ()

@end

@implementation DemoDrawImageCoreGraphics

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 30)];
    lbOriginalImage.text = @"Draw Image via CoreGraphics and QuartzCore...";
    lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbOriginalImage];
    
    // 使用Core Graphics绘制图片
    TouchDrawViewViaCoreGraphics *drawView = [[TouchDrawViewViaCoreGraphics alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 200)];
    drawView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:drawView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
