//
//  DemoDrawImageOpenGLES.m
//  OpenGLDemo
//
//  Created by Chris Hu on 16/1/10.
//  Copyright © 2016年 Chris Hu. All rights reserved.
//

#import "DemoDrawImageOpenGLES.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "ShaderOperations.h"

@interface DemoDrawImageOpenGLES () <UIImagePickerControllerDelegate>

@property (nonatomic) UIImage *originImage;
@property (nonatomic) UIImageView *originImageView;

@end

@implementation DemoDrawImageOpenGLES {

    EAGLContext *_eaglContext; // OpenGL context,管理使用opengl es进行绘制的状态,命令及资源
    CAEAGLLayer *_eaglLayer;

    GLuint _colorRenderBuffer; // 渲染缓冲区
    GLuint _frameBuffer; // 帧缓冲区
    
    GLuint _glProgram;
    GLuint _positionSlot; // 顶点
    GLuint _textureSlot;  // 纹理
    GLuint _textureCoordsSlot; // 纹理坐标
    
    GLuint _textureID; // 纹理ID
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self displayOriginImage];
 
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseOriginImageFromPhotos)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;
    [_originImageView addGestureRecognizer:tapGestureRecognizer];
    [_originImageView setUserInteractionEnabled:YES];
    
    [self didDrawImageViaOpenGLES:_originImage inFrame:CGRectMake(10, 340, self.view.frame.size.width - 20, 200)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayOriginImage {
    UILabel *lbOriginalImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 30)];
    lbOriginalImage.text = @"Click image to choose from local photos...";
    lbOriginalImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbOriginalImage];
    
    _originImage = [UIImage imageNamed:@"testImage"];
    _originImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 200)];
    _originImageView.image = _originImage;
    [self.view addSubview:_originImageView];
    
    UILabel *lbProcessedImage = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, self.view.frame.size.width - 20, 30)];
    lbProcessedImage.text = @"Processed image...";
    lbProcessedImage.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbProcessedImage];
}

- (void)chooseOriginImageFromPhotos {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage *savedImage = editedImage ? editedImage : originalImage;
    [picker dismissViewControllerAnimated:YES completion:^{
        _originImageView.image = savedImage;
        [self didDrawImageViaOpenGLES:savedImage inFrame:CGRectMake(10, 340, self.view.frame.size.width - 20, 200)];
    }];
}

#pragma mark - didDrawImageViaOpenGLES

- (void)didDrawImageViaOpenGLES:(UIImage *)image inFrame:(CGRect)rect {
    [self setupOpenGLContext];
    [self setupCAEAGLLayer:rect];
    
    [self tearDownOpenGLBuffers];
    [self setupOpenGLBuffers];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [self processShaders];
    
    _textureID = [self setupTexture:image];
    
    [self setupBlendMode];
    
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    [self render:rect];
    
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - setupOpenGLContext

- (void)setupOpenGLContext {
    //setup context, 渲染上下文，管理所有绘制的状态，命令及资源信息。
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //opengl es 2.0
    [EAGLContext setCurrentContext:_eaglContext]; //设置为当前上下文。
}

#pragma mark - setupCAEAGLLayer

- (void)setupCAEAGLLayer:(CGRect)rect {
    _eaglLayer = [CAEAGLLayer layer];
    _eaglLayer.frame = rect;
    _eaglLayer.opaque = YES;
    
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
    _glProgram = [ShaderOperations compileShaders:@"DemoDrawImageTextureVertex" shaderFragment:@"DemoDrawImageTextureFragment"];
    
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "Position");
    _textureSlot = glGetUniformLocation(_glProgram, "Texture");
    _textureCoordsSlot = glGetAttribLocation(_glProgram, "TextureCoords");
}

#pragma mark - setupTexture
// 加载image, 使用CoreGraphics将位图以RGBA格式存放.将UIImage图像数据转化成OpenGL ES接受的数据.
- (GLuint)setupTexture:(UIImage *)image {
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    glEnable(GL_TEXTURE_2D);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 将图像数据传递给到GL_TEXTURE_2D中
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

- (void)setupBlendMode {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
}

- (void)render:(CGRect)rect {
    GLfloat vertices[] = {
        -1, -1, 0,   //左下
        1,  -1, 0,   //右下
        -1, 1,  0,   //左上
        1,  1,  0 }; //右上
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    GLfloat texCoords[] = {
        0, 0,//左下
        1, 0,//右下
        0, 1,//左上
        1, 1,//右上
    };
    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    glEnableVertexAttribArray(_textureCoordsSlot);
    
    // 第一行和第三行不是严格必须的，默认使用GL_TEXTURE0作为当前激活的纹理单元
    glActiveTexture(GL_TEXTURE5); // 指定纹理单元GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, _textureID);
    glUniform1i(_textureSlot, 5); // 与纹理单元的序号对应
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
