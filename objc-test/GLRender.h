//  Created by applechang on 2017-5-10.
//  Copyright (c) 2017年 TENCENT. All rights reserved.

//#import <UIKit/UIKit.h>
#import "GLTexture.h"
//#import "GLiveGLUtil.h"
//#import "GLiveAVExternalEnum.h"
#import "IGLiveGLRender.h"
#import "IGLiveGLTexture.h"

@interface GLiveGLRender : NSObject<IGLiveGLRender>
{
    float      _xRotateMatrix[9];
    float      _yRotateMatrix[9];
    float      _zRotateMatrix[9];
    GLuint     _rotateXMatrixUniform;
    GLuint     _rotateYMatrixUniform;
    GLuint     _rotateZMatrixUniform;
    GLuint     _program;
    GLuint     _vertexVBO;
    GLuint     _textureVBO;
    GLuint     _indexVBO;
    GLuint     _indexCount;
    NSMutableArray* _renderFrameBuffer;
    id<IGLiveGLTexture>      _curRenderTexture;
    CGPoint      _texTopLeft;
    CGPoint      _texBottomLeft;
    CGPoint      _texTopRight;
    CGPoint      _texBottomRight;
    GLuint       _yuvTypeUniform;
    int          _width;
    int          _height;
}

@property (nonatomic,retain,getter=getContext) EAGLContext * context;
@end


@interface GLiveGLRenderYUV : GLiveGLRender<IGLiveGLYUVRender>
{
    GLuint _yPlaneTexture;
    GLuint _uPlaneTexture;
    GLuint _vPlaneTexture;
    GLuint _yPlaneUniform;
    GLuint _uPlaneUniform;
    GLuint _vPlaneUniform;
}
@end

@interface GLiveGLRenderPixelBuffer : GLiveGLRender<IGLiveGLPixelBufferRender>
{
    GLuint _samplerYUniform;
    GLuint _samplerUVUniform;
    
    CVOpenGLESTextureCacheRef _textureCache;
    GLuint _textures[2];
    
    CVOpenGLESTextureRef      _cvTexturesRef[2];
}
//- (void)setTexture:(GLTexture *)texture;
@end
