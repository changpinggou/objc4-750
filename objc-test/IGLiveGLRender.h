//  Created by applechang
//  Copyright © 2018年 tencent. All rights reserved.

#import <Foundation/Foundation.h>
//#import "IFalcoComponent.h"
//#include <OpenGLES/ES2/gl.h>
//#include <OpenGLES/ES2/glext.h>

typedef enum eGLiveVideoRotateAxis
{
    GLive_Rotation_Axis_X,
    GLive_Rotation_Axis_Y,
    GLive_Rotation_Axis_Z,
    
}GLIVE_VIDEO_ROTATE_AXIS;

typedef enum eGLiveVideoRotateType
{
    GLive_Rotation_Type_Vertex,
    GLive_Rotation_Type_Texture,
    
}GLIVE_VIDEO_ROTATE_TYPE;

@protocol IGLiveGLTexture;

@protocol IGLiveGLRender <NSObject>
@required
- (void)initWithSize:(CGSize)texSize;
- (void)prepareRender;
- (void)setTexture:(id<IGLiveGLTexture>)texture;
- (void)drawTexture:(id<IGLiveGLTexture>)texture
              viewX:(GLint)x
              viewY:(GLint)y
          viewWidth:(GLsizei)width
         viewHeight:(GLsizei)height;

- (void)setRotationWithDegree:(float)degrees
                     withAxis:(GLIVE_VIDEO_ROTATE_AXIS)axis
                     withType:(GLIVE_VIDEO_ROTATE_TYPE)rotateType;

- (void)clearRenderBuffer;
- (void)userCurrentGLProgram;
- (void)userCurrentContext;
- (EAGLContext*)getContext;
- (void)setWidth:(int)width;
- (int)getWidth;
- (void)setHeight:(int)height;
- (int)getHeight;
@end

@protocol IGLiveGLYUVRender <IGLiveGLRender>
@required
@end

@protocol IGLiveGLPixelBufferRender <IGLiveGLRender>
@required
@end
