//
//  ItemViewController.m
//  OpenGLDemo
//
//  Created by zj-db0352 on 15/7/29.
//  Copyright (c) 2015年 zj-db0352. All rights reserved.
//

#import "ItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ShaderOperations.h"
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, enumDemoOpenGL){
    demoClearColor = 0,
    demoShader,
    demoTriangle,
    demoCoreImageFilter,
    demoCoreImageOpenGLESFilter,
};

@interface ItemViewController ()

@property (nonatomic) NSArray *demosOpenGL;

@property (nonatomic) CAEAGLLayer *eaglLayer;
@property (nonatomic) EAGLContext *context; // OpenGL context,管理使用opengl es进行绘制的状态,命令及资源
@property (nonatomic) GLuint frameBuffer; // 帧缓冲区
@property (nonatomic) GLuint colorRenderBuffer; // 渲染缓冲区

@property (nonatomic) GLuint positionSlot; // ???
@property (nonatomic) GLuint colorSlot; // ???

// filters
@property (nonatomic) UIImage *originImage;

@end

@implementation ItemViewController

#pragma mark - viewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.demosOpenGL = @[@"Clear Color", @"shader", @"triangle", @"Core Image Filter", @"Core Image and OpenGS ES Filter"];
    
    [self setupOpenGLContext];
    [self setupCAEAGLLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = self.item;
    [self demoViaOpenGL];
}

#pragma mark - setupOpenGLContext

- (void)setupOpenGLContext {
    //setup context, 渲染上下文，管理所有绘制的状态，命令及资源信息。
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //opengl es 2.0
    [EAGLContext setCurrentContext:_context]; //设置为当前上下文。
}

#pragma mark - setupCAEAGLLayer

- (void)setupCAEAGLLayer {
    //setup layer, 必须要是CAEAGLLayer才行，
    //如果在viewController中，使用[self.view.layer addSublayer:eaglLayer];
    //如果在view中，可以直接重写UIView的layerClass类方法即可return [CAEAGLLayer class]。
    _eaglLayer = [CAEAGLLayer layer];//(CAEAGLLayer *)self.view.layer;
    _eaglLayer.frame = self.view.frame;
    _eaglLayer.opaque = YES; //CALayer默认是透明的
    //描绘属性：不维持渲染内容，颜色格式
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    [self.view.layer addSublayer:_eaglLayer];
}

#pragma mark - setupOpenGLBuffers

- (void)setupOpenGLBuffers {
    //先要renderbuffer，然后framebuffer，顺序不能互换。
    //setup renderbuffer
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //为color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];

    glGenFramebuffers(1, &_frameBuffer);
    //设置为当前framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

#pragma mark - tearDownOpenGLBuffers

- (void)tearDownOpenGLBuffers {
    //destory render and frame buffer
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
}

#pragma mark - demoViaOpenGL

- (void)demoViaOpenGL {
//    self.demosOpenGL = @[@"Clear Color", @"shader", @"triangle", @"Core Image Filter", @"Core Image and OpenGS ES Filter"];
    [self tearDownOpenGLBuffers];
    [self setupOpenGLBuffers];
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(10.0);
    switch ([self.demosOpenGL indexOfObject:self.item]) {
        case demoClearColor:
            [self setClearColor];
            break;
        case demoShader:
            [self drawShader];
            break;
        case demoTriangle:
            [self drawTriangle];
            break;
        case demoCoreImageFilter:
            [self filterViaCoreImage];
            break;
        case demoCoreImageOpenGLESFilter:
            [self filterViaCoreImageAndOpenGLES];
            break;
        default:
            break;
    }
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - draw somethings

- (void)setClearColor {
    glClearColor(0, 0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)drawShader {
    // 先要编译vertex和fragment两个shader
    NSString *shaderVertex = @"SimpleVertex";
    NSString *shaderFragment = @"SimpleFragment";
    [self compileShaders:shaderVertex shaderFragment:shaderFragment position:"Position"];

    // 定义一个Vertex结构
    typedef struct {
        float Position[3];
        float Color[4];
    } Vertex;
    
    // 跟踪每个顶点信息
    const Vertex Vertices[] = {
        {{1,-1,0}, {1,0,0,1}},
        {{1,1,0}, {0,1,0,1}},
        {{-1,1,0}, {0,0,1,1}},
        {{-1,-1,0}, {0,0,0,1}},
    };
    
    // 跟踪组成每个三角形的索引信息
    const GLubyte Indices[] = {
        0,1,2,
        2,3,0
    };
    
    //
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    //把数据传到OpenGL
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);

    //设置UIView用于渲染的部分, 这里是整个屏幕
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //为vertex shader的两个输入参数设置合适的值
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float)*3));
    //在每个vertex上调用vertex shader, 每个像素调用fragment shader, 最终画出图形
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

- (void)drawTriangle {
    // 先要编译vertex和fragment两个shader
    NSString *shaderVertex = @"VertexTriangle";
    NSString *shaderFragment = @"FragmentTriangle";
    [self compileShaders:shaderVertex shaderFragment:shaderFragment position:"vPosition"];
    
    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };

    //设置UIView用于渲染的部分, 这里是整个屏幕
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    // Load the vertex data
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

#pragma mark - shader related

- (void)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment position:(const char *)position{
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
    
    // 5 获取指向vertex shader传入变量的指针, 然后就通过该指针来使用
    _positionSlot = glGetAttribLocation(programHandle, position);
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot); // 启用这些数据
    glEnableVertexAttribArray(_colorSlot); 
}

#pragma mark - filters

- (void)displayOriginImage {
    _originImage = [UIImage imageNamed:@"testImage"];
    UIImageView *originImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 64, self.view.frame.size.width - 20, 280)];
    originImageView.image = _originImage;
    [self.view addSubview:originImageView];
}

- (void)filterViaCoreImage {
    [self displayOriginImage];

    // 0. 导入CIImage图片
    CIImage *ciInputImage = [[CIImage alloc] initWithImage:_originImage];
    // 1. 创建CIFilter
    CIFilter *filterPixellate = [CIFilter filterWithName:@"CIPixellate"];
    [filterPixellate setValue:ciInputImage forKey:kCIInputImageKey];
    [filterPixellate setDefaults];
    CIImage *ciOutImagePixellate = [filterPixellate valueForKey:kCIOutputImageKey];
    NSLog(@"filterPixellate : %@", filterPixellate.attributes);
    
    // 2. 用CIContext将滤镜中的图片渲染出来
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciOutImagePixellate fromRect:[ciOutImagePixellate extent]];
    
    // 3. 导出图片
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    // 4. 显示图片
    UIImageView *filteredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 360, self.view.frame.size.width - 20, 280)];
    filteredImageView.image = filteredImage;
    [self.view addSubview:filteredImageView];
}

- (void)filterViaCoreImageAndOpenGLES {
    [self displayOriginImage];

    // 获取OpenGLES渲染的context
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 创建出渲染的buffer
    GLKView *glkView = [[GLKView alloc] initWithFrame:CGRectMake(10, 360, self.view.frame.size.width - 20, 280) context:eaglContext];
    [glkView bindDrawable];
    [self.view addSubview:glkView];
    
    // 创建CoreImage使用的context
    CIContext *ciContext = [CIContext contextWithEAGLContext:eaglContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    
    // CoreImage的相关设置
    CIImage *ciImage = [[CIImage alloc] initWithImage:_originImage];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    [ciFilter setValue:@(3) forKey:kCIInputIntensityKey];

    // 开始渲染
    [ciContext drawImage:[ciFilter outputImage] inRect:CGRectMake(0, 0, glkView.drawableWidth, glkView.drawableHeight) fromRect:[ciImage extent]];
    [glkView display];
    
}

@end
