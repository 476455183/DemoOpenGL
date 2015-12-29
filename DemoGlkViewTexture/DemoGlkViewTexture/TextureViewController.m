//
//  TextureViewController.m
//  DemoGlkViewTexture
//
//  Created by zj－db0465 on 15/12/29.
//  Copyright © 2015年 icetime17. All rights reserved.
//

#import "TextureViewController.h"

@interface TextureViewController ()

@end

@implementation TextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"Model.jpg"];
    [self.view addSubview:imageView];
    
    [self addBtnExit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBtnExit {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 30)];
    [btn setTitle:@"Exit" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionExit:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionExit:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
