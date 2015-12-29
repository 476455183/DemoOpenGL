//
//  DemoShaderViewController.m
//  OpenGLDemo
//
//  Created by zj－db0465 on 15/12/29.
//  Copyright © 2015年 zj-db0352. All rights reserved.
//

#import "DemoShaderViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "ShaderOperations.h"

@interface DemoShaderViewController ()

@end

@implementation DemoShaderViewController {

    EAGLContext *_eaglContext; // OpenGL context,管理使用opengl es进行绘制的状态,命令及资源
    CAEAGLLayer *_eaglLayer;
    
    GLuint _colorRenderBuffer; // 渲染缓冲区
    GLuint _frameBuffer; // 帧缓冲区
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self demo];
}

- (void)demo {
    [self setupOpenGLContext];
    [self setupCAEAGLLayer];
    
    [self tearDownOpenGLBuffers];
    [self setupOpenGLBuffers];
    
    // 设置清屏颜色
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    // 用来指定要用清屏颜色来清除由mask指定的buffer，此处是color buffer
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self drawShader];
    
    // 将指定renderBuffer渲染在屏幕上
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - setupOpenGLContext

- (void)setupOpenGLContext {
    //setup context, 渲染上下文，管理所有绘制的状态，命令及资源信息。
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //opengl es 2.0
    [EAGLContext setCurrentContext:_eaglContext]; //设置为当前上下文。
}

#pragma mark - setupCAEAGLLayer

- (void)setupCAEAGLLayer {
    //setup layer, 必须要是CAEAGLLayer才行，才能在其上描绘OpenGL内容
    //如果在viewController中，使用[self.view.layer addSublayer:eaglLayer];
    //如果在view中，可以直接重写UIView的layerClass类方法即可return [CAEAGLLayer class]。
    _eaglLayer = [CAEAGLLayer layer];
    _eaglLayer.frame = self.view.frame;
    _eaglLayer.opaque = YES; //CALayer默认是透明的
    
    // 描绘属性：这里不维持渲染内容
    // kEAGLDrawablePropertyRetainedBacking:若为YES，则使用glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)计算得到的最终结果颜色的透明度会考虑目标颜色的透明度值。
    // 若为NO，则不考虑目标颜色的透明度值，将其当做1来处理。
    // 使用场景：目标颜色为非透明，源颜色有透明度，若设为YES，则使用glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)得到的结果颜色会有一定的透明度（与实际不符）。若未NO则不会（符合实际）。
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    [self.view.layer addSublayer:_eaglLayer];
}

#pragma mark - tearDownOpenGLBuffers

- (void)tearDownOpenGLBuffers {
    //destory render and frame buffer
    if (_colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

#pragma mark - setupOpenGLBuffers

- (void)setupOpenGLBuffers {
    //先要renderbuffer，然后framebuffer，顺序不能互换。
    
    // OpenGlES共有三种：colorBuffer，depthBuffer，stencilBuffer。
    // 生成一个renderBuffer，id是_colorRenderBuffer
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前renderBuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //为color renderbuffer 分配存储空间
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // FBO用于管理colorRenderBuffer，离屏渲染
    glGenFramebuffers(1, &_frameBuffer);
    //设置为当前framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)drawShader {
//    self compileShaders:@"SimpleVertex" shaderFragment:@"Ver"
}

#pragma mark - shader related
 
 - (void)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment {
     // 1 vertex和fragment两个shader都要编译
     GLuint vertexShader = [ShaderOperations compileShader:shaderVertex withType:GL_VERTEX_SHADER];
     GLuint fragmentShader = [ShaderOperations compileShader:shaderFragment withType:GL_FRAGMENT_SHADER];
     
     // 2 连接vertex和fragment shader成一个完整的program
     GLuint programHandle = glCreateProgram();
     glAttachShader(programHandle, vertexShader);
     glAttachShader(programHandle, fragmentShader);
     
     // link program
     glLinkProgram(programHandle);
     
     // 3 check link status
     GLint linkSuccess;
     glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
     if (linkSuccess == GL_FALSE) {
         GLchar messages[256];
         glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
         NSString *messageString = [NSString stringWithUTF8String:messages];
         NSLog(@"%@", messageString);
         exit(1);
     }
     
     // 4 让OpenGL执行program
     glUseProgram(programHandle);
     
//     // 5 获取指向vertex shader传入变量的指针, 然后就通过该指针来使用
//     // 即将_positionSlot 与 shader中的Position参数绑定起来
//     _positionSlot = glGetAttribLocation(programHandle, "Position");
//     
//     // 即将_colorSlot 与 shader中的SourceColor参数绑定起来
//     // 采用的是Attribute类型
//     _aColorSlot = glGetAttribLocation(programHandle, "ASourceColor");
//     // 采用的是uniform类型
//     _colorSlot = glGetUniformLocation(programHandle, "SourceColor");
//     
//     _modelViewSlot = glGetUniformLocation(programHandle, "ModelView");
//     _projectionSlot = glGetUniformLocation(programHandle, "Projection");
//     
//     _textureSlot = glGetUniformLocation(programHandle, "Texture");
//     _textureCoordsSlot = glGetAttribLocation(programHandle, "TextureCoords");
     // 在使用的地方, 调用glEnableVertexAttribArray以启用这些数据
 }

@end
