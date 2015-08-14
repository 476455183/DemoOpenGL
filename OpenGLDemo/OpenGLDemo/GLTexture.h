//
//  OpenGLTexture3D.h
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

@interface GLTexture : NSObject {
	GLuint		texture[1];
}
@property (nonatomic, readonly) GLuint textureID;
@property (nonatomic, assign) CGSize size;

- (id)initWithSize:(CGSize)size;
- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image repeat:(BOOL)isRepeat;
- (id)initWithFilename:(NSString *)filename;
- (id)initWithFilename:(NSString *)filename repeat:(BOOL)isRepeat;

- (void)resetImageData:(void*)imageData;

- (void)use;
+ (void)useDefaultTexture;
@end
