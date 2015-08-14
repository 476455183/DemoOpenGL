//
//  OpenGLTexture3D.m
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import "GLTexture.h"

@interface GLTexture (){
    BOOL _isRepeat;
}
@end

@implementation GLTexture

- (id)initWithSize:(CGSize)size
{
    if ((self = [super init]))
    {
        self.size = size;
        glGenTextures(1, &texture[0]);
        
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    return [self initWithImage:image repeat:NO];
}

- (id)initWithImage:(UIImage *)image repeat:(BOOL)isRepeat
{
    if ((self = [super init]))
	{
//		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
        
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
		glGenTextures(1, &texture[0]);
		glBindTexture(GL_TEXTURE_2D, texture[0]);

        _isRepeat = isRepeat;
        if (_isRepeat) {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
        else {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		
        if (image == nil)
            return nil;
        
        GLuint width = (GLuint)CGImageGetWidth(image.CGImage);
        GLuint height = (GLuint)CGImageGetHeight(image.CGImage);
        
        _size = CGSizeMake(width, height);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        void *imageData = malloc( height * width * 4 );
        CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        CGContextTranslateCTM (context, 0, height);
        CGContextScaleCTM (context, 1.0, -1.0);
        CGColorSpaceRelease( colorSpace );
        CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        CGContextRelease(context);
        
        free(imageData);
	}
	return self;
}

- (id)initWithFilename:(NSString *)filename
{
    return [self initWithFilename:filename repeat:NO];
}

- (id)initWithFilename:(NSString *)filename repeat:(BOOL)isRepeat
{
    NSString *extension = [filename pathExtension];
    NSString *baseFilenameWithExtension = [filename lastPathComponent];
    NSString *baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    return [self initWithImage:image repeat:isRepeat];
}

- (void)resetImageData:(void*)imageData
{
    if (texture[0]) {
        glDeleteTextures(1, &texture[0]);
    }
    glGenTextures(1, &texture[0]);
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    
    if (_isRepeat) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _size.width, _size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
}

- (GLuint)textureID
{
    return texture[0];
}

- (void)use
{
	glBindTexture(GL_TEXTURE_2D, texture[0]);
}

+ (void)useDefaultTexture
{
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)dealloc
{
	glDeleteTextures(1, &texture[0]);
    NSLog(@"getting down");
}

@end
