# OpenGLDemo
OpenGL Learning Demo

1. CAEAGLLayer，在CAEAGLLayer层上进行OpenGL的绘制.  
2. EAGLContext，创建OpenGL context，管理所有使用OpenGL ES进行绘制的状态，命令及资源信息。  
	需要生命API，设置为当前context  
3. 渲染缓冲区 renderbuffer，三种colorbuffer，depthbuffer，stencilbuffer  
	void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers) 将分配到的renderbuffer的id存于renderbuffers中。  
	void glBindRenderbuffer (GLenum target, GLuint renderbuffer) 将指定id的renderbuffer设置为当前renderbuffer。  
	(BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable 为renderbuffer分配存储空间
4. 帧缓冲区 framebuffer，  
	void glGenFramebuffers (GLsizei n, GLuint* framebuffers)  
	void glBindFramebuffer (GLenum target, GLuint framebuffer) 设置为当前framebuffer  
	void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) 将renderbuffer装配到attachment这个装配点上
5. 设置clearColor  
	glClearColor(1.0, 1.0, 1.0, 1.0) 设置clearColor  
	glClear(GL_COLOR_BUFFER_BIT)
6. 调用presentRenderbuffer方法, 将renderbuffer和colorbuffer呈现到UIView上.  
  
7. 着色器由类似C的语言GLSL编写.  
	Vertex shader: 顶点着色器. 如在长方形中vertex shader会被调用四次.  
		负责执行灯光, 几何变换等计算, 得出最终的顶点位置后, 为片段着色器提供数据.  
	Fragment shader: 片段着色器, 负责计算每个像素的最终颜色.  
	着色器使用之前要先编译,以及其他的一些操作.  
8. glVertexAttribPointer指定了渲染时索引值为index的顶点属性数组的数据格式和位置.  
	void glVertexAttribPointer( GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride,const GLvoid * pointer)  
	size和type分别指定每个顶点属性的组件数量和数据类型, normalized指定当被访问时, 固定点数据值是否应该被归一化或直接转换为固定点值.  
	stride指定连续顶点属性之间的偏移量, 用于描述每个vertex数据大小.  
	pointer指定第一个组件在数组的第一个顶点属性中的偏移量, 与GL_ARRAY_BUFFER绑定存储于缓冲区中.  
	如:  
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);  
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float)*3));  


9. 指定triangle的三个顶点, 然后调用glVertexAttribPointer和glEnableVertexAttribArray来加载vertex数据.  
	最后调用glDrawArrays(GL_TRIANGLES, 0, 3)来绘制triangle.  
10. 在compileShaders中的glGetAttribLocation方法, demo2中为"Position", 而demo3中绘制triangle时要指定为"vPosition". 有何不同?  


11. 使用CoreImage的filter.  
	导入CIImage图片->创建CIFilter->用CIContext将滤镜中的图片渲染出来->导出并显示图片.  
12. 使用CoreImage+OpenGL ES实现filter.  
	获取OpenGL ES渲染的context->创建渲染buffer->创建CoreImage使用的CIContext->设置CoreImage->渲染图片.  

13. 使用OpenGL ES绘制已有图片.  
	创建并添加GLKView到view, 调用[_glkView bindDrawable];和[_glkView display];  
	绘制长方形(通过vertex), 启用颜色.  
	启用vertex贴图坐标:  
		glEnableVertexAttribArray(GLKVertexAttribTexCoord0);  
    	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, texCoords);  
    	// 因为读取图片信息的时候默认是从图片左上角读取的, 而OpenGL绘制却是从左下角开始的.所以我们要从左下角开始读取图片数据.  
    	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(YES), GLKTextureLoaderOriginBottomLeft, nil];  
    	GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];  
    创建并设置GLKBaseEffect:  
    GLKBaseEffect *baseEffect = [[GLKBaseEffect alloc] init];  
    // 创建一个二维的投影矩阵, 即定义一个视野区域(镜头看到的东西)  
    // GLKMatrix4MakeOrtho(float left, float right, float bottom, float top, float nearZ, float farZ)  
    baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -1, 1);  
    baseEffect.texture2d0.name = textureInfo.name;  
    [baseEffect prepareToDraw];  
    // 最后绘制图片  
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);  
