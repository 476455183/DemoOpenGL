//
//  ViewController.m
//  DemoGlkViewTexture
//
//  Created by zj－db0465 on 15/12/29.
//  Copyright © 2015年 icetime17. All rights reserved.
//

#import "ViewController.h"
#import "TextureViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addBtnTexture];
    [self addBtnTextureVBO];
    [self addBtnTextureVAO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Texture
- (void)addBtnTexture {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    [btn setTitle:@"Texture" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionTexture:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionTexture:(UIButton *)sender {
    TextureViewController *textureVC = [[TextureViewController alloc] init];
    [self presentViewController:textureVC animated:YES completion:^{
        
    }];
}

#pragma mark - VBO
- (void)addBtnTextureVBO {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 50)];
    [btn setTitle:@"TextureVBO" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionTextureVBO:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionTextureVBO:(UIButton *)sender {
    
}

#pragma mark - VAO
- (void)addBtnTextureVAO {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 50)];
    [btn setTitle:@"TextureVAO" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionTextureVAO:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 2.0f;
    [self.view addSubview:btn];
}

- (void)actionTextureVAO:(UIButton *)sender {
    
}

@end
