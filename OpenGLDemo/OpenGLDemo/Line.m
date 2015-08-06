//
//  Line.m
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/8/6.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import "Line.h"

@implementation Line

@synthesize begin, end, color;

- (id)init {
    self = [super init];
    if (self) {
        [self setColor:[UIColor blackColor]];
    }
    return self;
}

@end
