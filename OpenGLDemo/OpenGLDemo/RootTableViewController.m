//
//  RootTableViewController.m
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/7/29.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import "RootTableViewController.h"
#import "ItemViewController.h"

@interface RootTableViewController ()

@property (nonatomic) NSArray *demosOpenGL;
@property (nonatomic) NSString *selectedItem;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"OpenGL Demos";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.demosOpenGL = @[@"Clear Color", @"shader", @"triangle", @"Core Image Filter", @"Core Image and OpenGS ES Filter", @"3D Transform"];
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

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedItem = (NSString *)self.demosOpenGL[indexPath.row];
    [self performSegueWithIdentifier:@"segueFromTableToCell" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemViewController *itemVC = (ItemViewController *)segue.destinationViewController;
    itemVC.item = self.selectedItem;
}

@end
