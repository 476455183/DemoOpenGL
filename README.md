# OpenGLDemo
OpenGL Learning Demo

1. EAGLContext, 渲染上下文，管理所有使用OpenGL ES进行绘制的状态，命令及资源信息。  
	需要设置为当前context  
2. renderbuffer，三种colorbuffer，depthbuffer，stencilbuffer  
	void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers) 将分配到的renderbuffer的id存于renderbuffers中。  
	void glBindRenderbuffer (GLenum target, GLuint renderbuffer) 将指定id的renderbuffer设置为当前renderbuffer。  
	(BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable 为renderbuffer分配存储空间
3. framebuffer，  
	void glGenFramebuffers (GLsizei n, GLuint* framebuffers)  
	void glBindFramebuffer (GLenum target, GLuint framebuffer) 设置为当前framebuffer  
	void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) 将renderbuffer装配到attachment这个装配点上
4. 设置clearColor  
	glClearColor(1.0, 1.0, 1.0, 1.0) 设置clearColor  
	glClear(GL_COLOR_BUFFER_BIT)
