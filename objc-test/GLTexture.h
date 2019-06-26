#import <Foundation/Foundation.h>
#import "IGLiveGLTexture.h"

@interface MyTestClass : NSObject
-(void)MyFunc;
@end

@interface GLTexture : NSObject<IGLiveGLTexture>
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@property (assign, nonatomic) CGFloat zRotateAngle;
@end

@interface GLTextureYUV : GLTexture<IGLiveGLTextureYUV>
@property (nonatomic, assign) uint8_t *Y;
@property (nonatomic, assign) uint8_t *U;
@property (nonatomic, assign) uint8_t *V;
@end

