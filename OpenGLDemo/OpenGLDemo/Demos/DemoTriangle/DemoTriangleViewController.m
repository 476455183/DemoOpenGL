//
//  DemoTriangleViewController.m
//  OpenGLDemo
//
//  Created by Chris Hu on 15/12/29.
//  Copyright © 2015年 Chris Hu. All rights reserved.
//

#import "DemoTriangleViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "ShaderOperations.h"

@interface DemoTriangleViewController ()

@end

@implementation DemoTriangleViewController {
    
    EAGLContext *_eaglContext; // OpenGL context,管理使用opengl es进行绘制的状态,命令及资源
    CAEAGLLayer *_eaglLayer;
    
    GLuint _colorRenderBuffer; // 渲染缓冲区
    GLuint _frameBuffer; // 帧缓冲区
    
    GLuint _glProgram;
    GLuint _positionSlot; // 用于绑定shader中的Position参数
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
    
    [self processShaders];
    
//    [self renderVertices];
//    [self renderUsingIndex];
//    [self renderUsingVBO];
    [self renderUsingIndexVBO];

    // 将指定renderBuffer渲染在屏幕上
    // 绘制三角形，红色是由fragment shader决定
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
    
    [self getResultImage];
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

- (void)processShaders {
    // 编译shaders
    _glProgram = [ShaderOperations compileShaders:@"DemoTriangleVertex" shaderFragment:@"DemoTriangleFragment"];
    
    glUseProgram(_glProgram);
    // 获取指向vertex shader传入变量的指针, 然后就通过该指针来使用
    // 即将_positionSlot 与 shader中的Position参数绑定起来
    glGetAttribLocation(_glProgram, "Position");
}

- (void)renderVertices {
    // 设置viewport
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    // Load the vertex data，(不使用VBO)则直接从CPU中传递顶点数据到GPU中进行渲染
    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)renderUsingIndex {
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    const GLubyte indices[] = {
        0,1,2
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
}

- (void)renderUsingVBO {
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 使用VBO时，最后一个参数0为要获取参数在GL_ARRAY_BUFFER中的偏移量
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)renderUsingIndexVBO {
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    const GLubyte indices[] = {
        0,1,2
    };
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 使用VBO时，最后一个参数0为要获取参数在GL_ARRAY_BUFFER中的偏移量
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
}

- (UIImage *)getResultImage {
    CGSize currentFBOSize = self.view.frame.size;
    NSUInteger totalBytesForImage = (int)currentFBOSize.width * (int)currentFBOSize.height * 4;
    
    GLubyte *_rawImagePixelsTemp = (GLubyte *)malloc(totalBytesForImage);
    
    glReadPixels(0, 0, (int)currentFBOSize.width, (int)currentFBOSize.height, GL_RGBA, GL_UNSIGNED_BYTE, _rawImagePixelsTemp);
    glUseProgram(0); //unbind the shader
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, _rawImagePixelsTemp, totalBytesForImage, (CGDataProviderReleaseDataCallback)&freeData);
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef cgImageFromBytes = CGImageCreate((int)currentFBOSize.width, (int)currentFBOSize.height, 8, 32, 4 * (int)currentFBOSize.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1.0 orientation:UIImageOrientationDownMirrored];
    
    CGImageRelease(cgImageFromBytes);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);

    return finalImage;
}

void freeData(void *info, const void *data, size_t size) {
    free((unsigned char *)data);
}

@end
