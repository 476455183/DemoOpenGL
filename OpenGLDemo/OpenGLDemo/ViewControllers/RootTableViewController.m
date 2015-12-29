//
//  RootTableViewController.m
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/7/29.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import "RootTableViewController.h"
#import "ItemViewController.h"


#import "DemoClearColorViewController.h"
#import "DemoShaderViewController.h"
#import "DemoTriangleViewController.h"

typedef NS_ENUM(NSUInteger, DemoOpenGLES) {
    kDemoClearColor = 0,
    kDemoShader,
    kDemoTriangleViaShader,
    kDemoImageViaCoreGraphics,
    kDemoImageViaOpenGLES,
    
    kDemoPaintViaCoreGraphics,
    kDemoPaintViaOpenGLES,
    kDemoPaintViaOpenGLESTexture,
    kDemoPaintFilterViaOpenGLESTexture,
    
    kDemoCoreImageFilter,
    kDemoCoreImageOpenGLESFilter,
    
    kDemoGLKView,
};


@interface RootTableViewController ()

@property (nonatomic) NSArray *demosOpenGL;
@property (nonatomic) NSString *selectedItem;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"OpenGL Demos";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.demosOpenGL = @[@"Clear Color",
                         @"Shader",
                         @"Draw Triangle via Shader",
                         @"Draw Image via Core Graphics",
                         @"Draw Image via OpenGL ES",
                         @"Paint via Core Graphics",
                         @"Paint via OpenGL ES",
                         @"Paint via OpenGL ES Texture",
                         @"Paint and Filter via OpenGLES Texture",
                         @"Core Image Filter",
                         @"Core Image and OpenGS ES Filter",
                         @"3D Transform",
                         @"GLKView Demo",
                         @"Paint via GLKView"
                         ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.demosOpenGL.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellOpenGL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.demosOpenGL[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kDemoClearColor) {
        DemoClearColorViewController *demoClearColor = [[DemoClearColorViewController alloc] init];
        demoClearColor.view.backgroundColor = [UIColor whiteColor];
        demoClearColor.navigationItem.title = @"DemoClearColor";
        [self.navigationController pushViewController:demoClearColor animated:YES];
        return;
    } else if (indexPath.row == kDemoShader) {
        DemoShaderViewController *demoShader = [[DemoShaderViewController alloc] init];
        demoShader.view.backgroundColor = [UIColor whiteColor];
        demoShader.navigationItem.title = @"DemoShader";
        [self.navigationController pushViewController:demoShader animated:YES];
        return;
    } else if (indexPath.row == kDemoTriangleViaShader) {
        DemoTriangleViewController *demoTriangle = [[DemoTriangleViewController alloc] init];
        demoTriangle.view.backgroundColor = [UIColor whiteColor];
        demoTriangle.navigationItem.title = @"DemoTriangleViaShader";
        [self.navigationController pushViewController:demoTriangle animated:YES];
        return;
    }
    
    
    self.selectedItem = (NSString *)self.demosOpenGL[indexPath.row];
    [self performSegueWithIdentifier:@"segueFromTableToCell" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemViewController *itemVC = (ItemViewController *)segue.destinationViewController;
    itemVC.item = self.selectedItem;
}

@end
