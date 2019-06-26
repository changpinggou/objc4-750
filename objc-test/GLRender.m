#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#define __FILE__ "GLRender.m"
#pragma clang diagnostic pop


#import "GLRender.h"

#define LIVE_HOSTESS_TO_BE_PROCESSED_FRAME_MAX 30
#define LIVE_RECEV_TO_BE_PROCESSED_FRAME_MAX   30

@implementation GLiveGLRender

-(void)initWithSize:(CGSize)texSize;
{
    self.height = texSize.height;
    self.width = texSize.width;
    for (int i=0; i<9; i++)
    {
        if (i%4 == 0) {
            _xRotateMatrix[i] = 1;
            _yRotateMatrix[i] = 1;
            _zRotateMatrix[i] = 1;
        }else{
            _xRotateMatrix[i] = 0;
            _yRotateMatrix[i] = 0;
            _zRotateMatrix[i] = 0;
        }
    }
    
    _texTopLeft.x = 0;
    _texTopLeft.y = 0;
    _texBottomLeft.x = 0;
    _texBottomLeft.y = 1;
    _texTopRight.x = 1;
    _texTopRight.y = 0;
    _texBottomRight.x = 1;
    _texBottomRight.y = 1;
    
    [self setupContext];
}

-(void)dealloc
{
}

- (void)setupContext
{
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        //GLiveLogFinal("Failed to initialize OpenGLES 2.0 context");
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        //GLiveLogFinal("Failed to set current OpenGL context");
    }
}

- (EAGLContext*)getContext
{
    return _context;
}

- (void)setupVBO
{
    /*
    GLfloat glivetexCoords[] = {
        1.0f, 0.0f, //右上
        1.0f, 1.0f, //右下
        0.0f, 1.0f, //左下
        0.0f, 0.0f, //左上
    };
    */
    
    GLfloat glivetexCoords[] = {
        _texTopRight.x,    _texTopRight.y,    //右上
        _texBottomRight.x, _texBottomRight.y, //右下
        _texBottomLeft.x,  _texBottomLeft.y,  //左下
        _texTopLeft.x,     _texTopLeft.y,     //左上
    };
    
    glGenBuffers(1, &_textureVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _textureVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(glivetexCoords), glivetexCoords, GL_DYNAMIC_DRAW);
    
    const GLfloat vertices[] = {
        1.0f,  1.0f,  0,      //右上
        1.0f,  -1.0f, 0,      //右下
        -1.0f, -1.0f, 0,      //左下
        -1.0f,  1.0f, 0,      //左上
    };
    
    glGenBuffers(1, &_vertexVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    
    const GLubyte indices[] = {
        0,1,2,
        2,3,0
    };
    glGenBuffers(1, &_indexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    _indexCount = sizeof(indices)/sizeof(indices[0]);
}

- (void) setRotationWithDegree:(float)degrees
                      withAxis:(GLIVE_VIDEO_ROTATE_AXIS)axis
                      withType:(GLIVE_VIDEO_ROTATE_TYPE)rotateType;
{
    float radians = degrees * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    if (GLive_Rotation_Type_Vertex == rotateType) {
        if (axis == GLive_Rotation_Axis_X) {

            //[1.0, 0.0, 0.0,
            // 0.0, c, s,
            //0.0, -s, c]
            _xRotateMatrix[4] = c;
            _xRotateMatrix[5] = s;
            _xRotateMatrix[7] = -s;
            _xRotateMatrix[8] = c;
        }else if(axis == GLive_Rotation_Axis_Y)
        {
            //[c, 0.0, -s,
            // 0.0, 1.0, 0.0,
            //-s, 0.0, c]
            _yRotateMatrix[0] = c;
            _yRotateMatrix[2] = -s;
            _yRotateMatrix[6] = -s;
            _yRotateMatrix[8] = c;
        }else if(axis == GLive_Rotation_Axis_Z)
        {
            //[c, s, 0.0,
            //-s, c, 0.0,
            //0.0, 0.0, 1.0]
            
            _zRotateMatrix[0] = c;
            _zRotateMatrix[1] = s;
            _zRotateMatrix[3] = -s;
            _zRotateMatrix[4] = c;
        }
    }
}

- (void)prepareRender
{
}

- (void)setTexture:(id<IGLiveGLTexture>)texture
{
}

-(void)clearRenderBuffer
{
    [self userCurrentContext];
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)setupGLProgram
{
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"resource/GLES_Shader/glivevert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"resource/GLES_Shader/glivefrag.glsl" ofType:nil];
    
    NSError* error = nil;
    NSString* vertString = [NSString stringWithContentsOfFile:vertFile
                                                     encoding:NSUTF8StringEncoding error:&error];
    if (!vertString) {
        NSLog(@"Error loading shader: %@, error: %@", vertFile, error.localizedDescription);
        exit(1);
    }
    
    NSString* fragString = [NSString stringWithContentsOfFile:fragFile
                                                     encoding:NSUTF8StringEncoding error:&error];
    if (!fragString) {
        NSLog(@"Error loading shader: %@, error: %@", fragString, error.localizedDescription);
        exit(1);
    }
    
    _program = createGLProgram(vertString.UTF8String, fragString.UTF8String);
    glUseProgram(_program);
    
    _yuvTypeUniform = glGetUniformLocation(_program, "yuvType");
    
    _rotateXMatrixUniform = glGetUniformLocation(_program, "rotateXMatrix");
    _rotateYMatrixUniform = glGetUniformLocation(_program, "rotateYMatrix");
    _rotateZMatrixUniform = glGetUniformLocation(_program, "rotateZMatrix");
}

-(void)userCurrentContext
{
    if (self.context && [EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Success to set current OpenGL context");
    }else{
        NSLog(@"Failed to set current OpenGL context");
    }
}

-(void)userCurrentGLProgram;
{
    glUseProgram(_program);
}

- (void)drawTexture:(GLTexture *)texture viewX:(GLint)x viewY:(GLint)y viewWidth:(GLsizei)width viewHeight:(GLsizei)height
{
    
}

-(int)getWidth
{
    return _width;
}
-(void)setWidth:(int)width
{
    _width = width;
}
-(int)getHeight
{
    return _height;
}
-(void)setHeight:(int)height
{
    _height = height;
}
@end


////////////////GLRenderYUV//////////////////////////
@implementation GLiveGLRenderYUV

- (void)initWithSize:(CGSize)texSize
{
    [super initWithSize:texSize];
    
    _renderFrameBuffer = [NSMutableArray arrayWithCapacity: LIVE_RECEV_TO_BE_PROCESSED_FRAME_MAX];
    _curRenderTexture = nil;
    
    if ((texSize.height == 480) && (texSize.width == 640))
    {
        //由于流控配置里会是368,所有要调整纹理高度贴图区域，为了进度，暂时只能做这种丑陋的事了
        int offsetH = (480 - 368)/(2*480);
        _texTopLeft.y += offsetH;
        _texTopRight.y += offsetH;
        _texBottomLeft.y -= offsetH;
        _texBottomRight.y -= offsetH;
    }
    [self setupGLProgram];
    [self setupVBO];
    
    _yPlaneTexture = createTexture2D(GL_LUMINANCE, texSize.width, texSize.height, NULL);
    _uPlaneTexture = createTexture2D(GL_LUMINANCE, texSize.width/2, texSize.height/2, NULL);
    _vPlaneTexture = createTexture2D(GL_LUMINANCE, texSize.width/2, texSize.height/2, NULL);
}

-(void)dealloc
{
    [EAGLContext setCurrentContext:self.context];
    glDeleteProgram(_program);
    _program = 0;
    
    glDeleteBuffers(1, &_vertexVBO);
    _vertexVBO = 0;
    
    glDeleteBuffers(1, &_indexVBO);
    _indexVBO = 0;
    
    glDeleteBuffers(1, &_textureVBO);
    _textureVBO = 0;
    
    glDeleteTextures(1, &_yPlaneTexture);
    _yPlaneTexture = 0;
    
    glDeleteTextures(1, &_uPlaneTexture);
    _uPlaneTexture = 0;
    
    glDeleteTextures(1, &_vPlaneTexture);
    _vPlaneTexture = 0;
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }

    self.context = nil;
    _curRenderTexture = nil;
}

- (void)setupGLProgram
{
    [super setupGLProgram];
    _yPlaneUniform = glGetUniformLocation(_program, "yPlane");
    _uPlaneUniform = glGetUniformLocation(_program, "uPlane");
    _vPlaneUniform = glGetUniformLocation(_program, "vPlane");
}

- (void)setTexture:(id<IGLiveGLTexture>)texture
{
    _curRenderTexture = texture;
}

- (void)drawTexture:(id<IGLiveGLTexture>)texture viewX:(GLint)x viewY:(GLint)y viewWidth:(GLsizei)width viewHeight:(GLsizei)height
{
    [self userCurrentContext];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(x, y, width, height);
    [self bindTexture:texture];
 
    glBindBuffer(GL_ARRAY_BUFFER, _textureVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _yPlaneTexture);
    glUniform1i(_yPlaneUniform, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _uPlaneTexture);
    glUniform1i(_uPlaneUniform, 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _vPlaneTexture);
    glUniform1i(_vPlaneUniform, 2);
    
    glUniformMatrix3fv(_rotateXMatrixUniform, 1, 0, _xRotateMatrix);
    glUniformMatrix3fv(_rotateYMatrixUniform, 1, 0, _yRotateMatrix);
    glUniformMatrix3fv(_rotateZMatrixUniform, 1, 0, _zRotateMatrix);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);

    glDrawElements(GL_TRIANGLE_STRIP, _indexCount, GL_UNSIGNED_BYTE, 0);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void) bindTexture:(id<IGLiveGLTexture>)texture
{
    if (texture == nil) {
        return;
    }
    
    if ([texture conformsToProtocol:@protocol(IGLiveGLTextureYUV)]) {
        GLTextureYUV *yuvTexture = (GLTextureYUV *)texture;
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        glBindTexture(GL_TEXTURE_2D, _yPlaneTexture);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, [texture getWidth], [texture getHeight], GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvTexture.Y);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glBindTexture(GL_TEXTURE_2D, _uPlaneTexture);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, [texture getWidth]/2, [texture getHeight]/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvTexture.U);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glBindTexture(GL_TEXTURE_2D, _vPlaneTexture);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, [texture getWidth]/2, [texture getHeight]/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, yuvTexture.V);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void)prepareRender
{
    if (![_curRenderTexture conformsToProtocol:@protocol(IGLiveGLTextureYUV)]) {
        return;
    }

    
    GLTextureYUV *yuvTexture = (GLTextureYUV *)_curRenderTexture;
    if (yuvTexture == nil) {
        return;
    }
    
    if ([yuvTexture getDirtyFlag] == YES) {
        if ([yuvTexture getAsMemHolder] == NO) {
            //如果该帧已经使用过且他的帧数据没有自己持有，就不要绘制，可能外部释放了
            return;
        }
    }

    
    [yuvTexture setDirtyFlag:YES];
    
//    if (_renderFrameBuffer.count > 0)
//    {
//        _curRenderTexture = [_renderFrameBuffer objectAtIndex:0];
//        [_renderFrameBuffer removeObjectAtIndex:0];
//    }else if(_curRenderTexture == nil){
//        return;
//    }
    
    glUniform1i(_yuvTypeUniform, 0);
    [self bindTexture:_curRenderTexture];
    
    glBindBuffer(GL_ARRAY_BUFFER, _textureVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));

    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _yPlaneTexture);
    glUniform1i(_yPlaneUniform, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _uPlaneTexture);
    glUniform1i(_uPlaneUniform, 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _vPlaneTexture);
    glUniform1i(_vPlaneUniform, 2);
    
    glUniformMatrix3fv(_rotateXMatrixUniform, 1, 0, _xRotateMatrix);
    glUniformMatrix3fv(_rotateYMatrixUniform, 1, 0, _yRotateMatrix);
    glUniformMatrix3fv(_rotateZMatrixUniform, 1, 0, _zRotateMatrix);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glDrawElements(GL_TRIANGLE_STRIP, _indexCount, GL_UNSIGNED_BYTE, 0);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [self.context presentRenderbuffer:GL_RENDERBUFFER];

}

-(void)userCurrentContext
{
    if (self.context && [EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Success to set current OpenGL context");
    }else{
        NSLog(@"Failed to set current OpenGL context");
    }
}

-(void)userCurrentGLProgram;
{
    glUseProgram(_program);
}

@end


@implementation GLiveGLRenderPixelBuffer
- (void)initWithSize:(CGSize)texSize
{
    [super initWithSize:texSize];
    [self setupGLProgram];
    [self setupVBO];
}

- (void)setupContext
{
    [super setupContext];
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_textureCache);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d\n", err);
    }
}

- (void)setTexture:(id<IGLiveGLTexture>)texture
{
    if ([texture conformsToProtocol:@protocol(IGLiveGLTexturePixelBuffer)]) {
        GLTexturePixelBuffer *pixelBufTexture = (GLTexturePixelBuffer *)texture;
        
        for (int i = 0; i < 2; ++i) {
            if (_cvTexturesRef[i]) {
                CFRelease(_cvTexturesRef[i]);
                _cvTexturesRef[i] = 0;
                _textures[i] = 0;
            }
        }
        
        if ([pixelBufTexture getTextureCache]) {
            CVOpenGLESTextureCacheFlush(_textureCache, 0);
        }
        
        if (_textures[0]) {
            glDeleteTextures(2, _textures);
        }
        
        size_t frameWidth  = pixelBufTexture.width;
        size_t frameHeight = pixelBufTexture.height;
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                     _textureCache,
                                                     [pixelBufTexture getTextureCache],
                                                     NULL,
                                                     GL_TEXTURE_2D,
                                                     GL_RED_EXT,
                                                     (GLsizei)frameWidth,
                                                     (GLsizei)frameHeight,
                                                     GL_RED_EXT,
                                                     GL_UNSIGNED_BYTE,
                                                     0,
                                                     &_cvTexturesRef[0]);
        _textures[0] = CVOpenGLESTextureGetName(_cvTexturesRef[0]);
        glBindTexture(CVOpenGLESTextureGetTarget(_cvTexturesRef[0]), _textures[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                     _textureCache,
                                                     [pixelBufTexture getTextureCache],
                                                     NULL,
                                                     GL_TEXTURE_2D,
                                                     GL_RG_EXT,
                                                     (GLsizei)frameWidth / 2,
                                                     (GLsizei)frameHeight / 2,
                                                     GL_RG_EXT,
                                                     GL_UNSIGNED_BYTE,
                                                     1,
                                                     &_cvTexturesRef[1]);
        _textures[1] = CVOpenGLESTextureGetName(_cvTexturesRef[1]);
        glBindTexture(CVOpenGLESTextureGetTarget(_cvTexturesRef[1]), _textures[1]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }

}

- (void)prepareRender
{
    glUniform1i(_yuvTypeUniform, 2);
    
    glBindBuffer(GL_ARRAY_BUFFER, _textureVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[0]);
    glUniform1i(_samplerYUniform, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _textures[1]);
    glUniform1i(_samplerUVUniform, 1);
    
    glUniformMatrix3fv(_rotateXMatrixUniform, 1, 0, _xRotateMatrix);
    glUniformMatrix3fv(_rotateYMatrixUniform, 1, 0, _yRotateMatrix);
    glUniformMatrix3fv(_rotateZMatrixUniform, 1, 0, _zRotateMatrix);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glDrawElements(GL_TRIANGLE_STRIP, _indexCount, GL_UNSIGNED_BYTE, 0);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupGLProgram
{
    [super setupGLProgram];
    _samplerYUniform = glGetUniformLocation(_program, "samplerY");
    _samplerUVUniform = glGetUniformLocation(_program, "samplerUV");
}

-(void)clearRenderBuffer
{
    [super clearRenderBuffer];
    for (int i = 0; i < 2; ++i) {
        if (_cvTexturesRef[i]) {
            CFRelease(_cvTexturesRef[i]);
            _cvTexturesRef[i] = 0;
            _textures[i] = 0;
        }
    }
        
    if (_textures[0]) {
        glDeleteTextures(2, _textures);
    }
}
@end

