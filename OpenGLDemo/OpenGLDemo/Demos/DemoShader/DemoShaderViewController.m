//
//  DemoShaderViewController.m
//  OpenGLDemo
//
//  Created by Chris Hu on 15/12/29.
//  Copyright © 2015年 Chris Hu. All rights reserved.
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
    
    GLuint _glProgram;
    GLuint _positionSlot;   // 用于绑定shader中的Position参数
    GLuint _colorSlot;      // 用于绑定shader中的SourceColor参数
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
    
    [self render];
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
    _glProgram = [ShaderOperations compileShaders:@"DemoShaderVertex" shaderFragment:@"DemoShaderFragment"];
    
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "Position");
    _colorSlot = glGetAttribLocation(_glProgram, "SourceColor");
}

- (void)render {
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
//    [self renderVertices];      // 直接使用顶点数组
//    [self renderUsingIndex];    // 使用顶点索引数组
//    [self renderUsingVBO];      // 使用VBO
    [self renderUsingIndexVBO];   // 使用索引数组+VBO
    
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - 直接使用顶点数组，即单纯使用glDrawArrays

- (void)renderVertices {
//    [self renderVertices_triangles];
    [self renderVertices_triangle_strip];
//    [self renderVertices_triangle_fan];
}

#pragma mark GL_TRIANGLES

- (void)renderVertices_triangles {
    // 顶点数组
    const GLfloat Vertices[] = {
        -1,-1,0,// 左下，黑色
        1,-1,0, // 右下，红色
        -1,1,0, // 左上，蓝色
        
        1,-1,0, // 右下，红色
        -1,1,0, // 左上，蓝色
        1,1,0,  // 右上，绿色
    };
    
    // 颜色数组
    const GLfloat Colors[] = {
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,0,1,1, // 左上，蓝色
        
        1,0,0,1, // 右下，红色
        0,0,1,1, // 左上，蓝色
        0,1,0,1, // 右上，绿色
    };
    
    // 纯粹使用顶点的方式，颜色与顶点要一一对应。
    // 在shader中DestinationColor为最终要传递给OpenGLES的颜色，要使用varying，即两个顶点之间颜色平滑渐变
    // 若不使用varying，则完全花掉。
    
    // 取出Vertices数组中的坐标点值，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 0, Colors);
    glEnableVertexAttribArray(_colorSlot);
    
    // 以上两个slot分别于着色器脚本中的Positon，SourceColor两个参数
    
    // 绘制两个三角形，不复用顶点，因此需要6个顶点坐标。
    // V0-V1-V2, V3-V4-V5
    
    /**
     *  参数1：三角形组合方式
     *  参数2：从顶点数组的哪个offset开始
     *  参数3：顶点个数6个
     */
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
    
#pragma mark GL_TRIANGLE_STRIP

- (void)renderVertices_triangle_strip {
    // 顶点数组
    const GLfloat Vertices[] = {
        -1,-1,0,// 左下，黑色
        1,-1,0, // 右下，红色
        -1,1,0, // 左上，蓝色
        1,1,0,  // 右上，绿色
    };
    
    // 颜色数组
    const GLfloat Colors[] = {
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,0,1,1, // 左上，蓝色
        0,1,0,1, // 右上，绿色
    };

    // 取出Vertices数组中的坐标点值，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 0, Colors);
    glEnableVertexAttribArray(_colorSlot);
    
    // 绘制两个三角形，复用两个顶点，因此只需要四个顶点坐标
    // V0-V1-V2, V1-V2-V3
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark GL_TRIANGLE_FAN

- (void)renderVertices_triangle_fan {
    // 顶点数组
    const GLfloat Vertices[] = {
        -1,1,0, // 左上，蓝色
        -1,-1,0,// 左下，黑色
        1,-1,0, // 右下，红色
        1,1,0,  // 右上，绿色
    };

    // 颜色数组
    const GLfloat Colors[] = {
        0,0,1,1, // 左上，蓝色
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,1,0,1, // 右上，绿色
    };

    // 取出Vertices数组中的坐标点值，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
    glEnableVertexAttribArray(_positionSlot);

    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 0, Colors);
    glEnableVertexAttribArray(_colorSlot);

    // 绘制两个三角形，复用两个顶点，因此只需要四个顶点坐标
    // V0-V1-V2, V0-V2-V3
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

#pragma mark - 使用顶点索引数组，使用glDrawElements

- (void)renderUsingIndex {
    // 顶点数组
    const GLfloat Vertices[] = {
        -1,-1,0,// 左下，黑色
        1,-1,0, // 右下，红色
        -1,1,0, // 左上，蓝色
        1,1,0,  // 右上，绿色
    };
    
    // 颜色数组
    const GLfloat Colors[] = {
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,0,1,1, // 左上，蓝色
        0,1,0,1, // 右上，绿色
    };
    
    // 索引数组，指定好了绘制三角形的方式
    // 与glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);一样。
    const GLubyte Indices[] = {
        0,1,2, // 三角形0
        1,2,3  // 三角形1
    };
    
    // 取出Vertices数组中的坐标点值，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // 注意，未使用VBO时，glVertexAttribPointer的最后一个参数是指向对应数组的指针。
    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 0, Colors);
    glEnableVertexAttribArray(_colorSlot);
    
    /**
     *  参数1：三角形组合方式
     *  参数2：索引数组中的元素个数，即6个元素，才能绘制矩形
     *  参数3：索引数组中的元素类型
     *  参数4：索引数组
     */
    // 注意，未使用VBO时，glDrawElements的最后一个参数是指向对应索引数组的指针。
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, Indices);
    
    /**
     *  结论：
     *  不管使用哪种方式，顶点和颜色两个数组一定要一一对应。
     *  glDrawArrays:
     *  glDrawElements: 引入了索引，则很方便地实现顶点的复用。
     *
     *  在每个vertex上调用我们的vertex shader，以及每个像素调用fragment shader
     *  相比glDrawArray, 使用顶点索引数组可减少存储和绘制重复顶点的资源消耗
     */
}

#pragma mark - 使用VBO，Vertex Buffer Object

- (void)renderUsingVBO {
    // 定义一个Vertex结构, 其中包含了坐标和颜色
    typedef struct {
        float Position[3];
        float Color[4];
    } Vertex;
    
    // 顶点数组
    const Vertex Vertices[] = {
        {{-1,-1,0}, {0,0,0,1}},// 左下，黑色
        {{1,-1,0}, {1,0,0,1}}, // 右下，红色
        {{-1,1,0}, {0,0,1,1}}, // 左上，蓝色
        {{1,1,0}, {0,1,0,1}},  // 右上，绿色
    };
    
    // GL_ARRAY_BUFFER用于顶点数组
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER，
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 给VBO传递数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    // 注意，未使用VBO时，glVertexAttribPointer的最后一个参数是指向对应数组的指针。
    // 但是，当使用VBO时，glVertexAttribPointer的最后一个参数是要获取的参数在GL_ARRAY_BUFFER（每一个Vertex）的偏移量
    // 取出Vertex结构体的Position，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glEnableVertexAttribArray(_positionSlot);
    
    // 注意，未使用VBO时，glVertexAttribPointer的最后一个参数是指向对应数组的指针。
    // 但是，当使用VBO时，glVertexAttribPointer的最后一个参数是要获取的参数在GL_ARRAY_BUFFER（每一个Vertex）的偏移量
    // Vertex结构体，偏移3个float的位置，即是Color值
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3));
    glEnableVertexAttribArray(_colorSlot);
    
    // 使用glDrawArrays也可绘制，此时仅从GL_ARRAY_BUFFER中取出顶点数据，
    // 而索引数组就可以不要了，即GL_ELEMENT_ARRAY_BUFFER实际上没有用到。
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)renderUsingIndexVBO {
    // 定义一个Vertex结构, 其中包含了坐标和颜色
    typedef struct {
        float Position[3];
        float Color[4];
    } Vertex;
    
    // 顶点数组
    const Vertex Vertices[] = {
        {{-1,-1,0}, {0,0,0,1}},// 左下，黑色
        {{1,-1,0}, {1,0,0,1}}, // 右下，红色
        {{-1,1,0}, {0,0,1,1}}, // 左上，蓝色
        {{1,1,0}, {0,1,0,1}},  // 右上，绿色
    };
    
    // 索引数组
    const GLubyte Indices[] = {
        0,1,2, // 三角形0
        1,2,3  // 三角形1
    };
    
    // setup VBOs
    
    // GL_ARRAY_BUFFER用于顶点数组
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER，
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 给VBO传递数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    // GL_ELEMENT_ARRAY_BUFFER用于顶点数组对应的Indices，即索引数组
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    // 注意，未使用VBO时，glVertexAttribPointer的最后一个参数是指向对应数组的指针。
    // 但是，当使用VBO时，glVertexAttribPointer的最后一个参数是要获取的参数在GL_ARRAY_BUFFER（每一个Vertex）的偏移量
    // 取出Vertex结构体的Position，赋给_positionSlot
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glEnableVertexAttribArray(_positionSlot);
    
    // 注意，未使用VBO时，glVertexAttribPointer的最后一个参数是指向对应数组的指针。
    // 但是，当使用VBO时，glVertexAttribPointer的最后一个参数是要获取的参数在GL_ARRAY_BUFFER（每一个Vertex）的偏移量
    // Vertex结构体，偏移3个float的位置，即是Color值
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3));
    glEnableVertexAttribArray(_colorSlot);
    
    // 使用glDrawArrays也可绘制，此时仅从GL_ARRAY_BUFFER中取出顶点数据，
    // 而索引数组就可以不要了，即GL_ELEMENT_ARRAY_BUFFER实际上没有用到。
    // glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    // 而使用glDrawElements的方式：本身就用到了索引，即GL_ELEMENT_ARRAY_BUFFER。
    // 所以，GL_ARRAY_BUFFER和GL_ELEMENT_ARRAY_BUFFER两个都需要。
    
    /**
     *  参数1：三角形组合方式
     *  参数2：索引数组中的元素个数，即6个元素，才能绘制矩形
     *  参数3：索引数组中的元素类型
     *  参数4：索引数组在GL_ELEMENT_ARRAY_BUFFER（索引数组）中的偏移量
     */
    // 注意，未使用VBO时，glDrawElements的最后一个参数是指向对应索引数组的指针。
    // 但是，当使用VBO时，参数4表示索引数据在VBO（GL_ELEMENT_ARRAY_BUFFER）中的偏移量
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

@end
