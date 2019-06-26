//  Created by applechang
//  Copyright © 2018年 tencent. All rights reserved.

#import <Foundation/Foundation.h>
//#import "IFalcoComponent.h"
//#import <UIKit/UIKit.h>

@protocol IGLiveGLTexture <NSObject>
@required
-(void)setWidth:(int)width;
-(int)getWidth;

-(void)setHeight:(int)height;
-(int)getHeight;

-(void)setZRotateAngle:(CGFloat)angle;
-(CGFloat)getZRotateAngle;

- (void)deleteTexture;
+ (void)testIGLiveGLTexture;
@property (nonatomic, assign)int flag;
@end

@protocol IGLiveGLTextureYUV <IGLiveGLTexture>
@required
-(void)setYPlane:(uint8_t*)Y;
-(uint8_t*)getYPlane;

-(void)setUPlane:(uint8_t*)U;
-(uint8_t*)getUPlane;

-(void)setVPlane:(uint8_t*)V;
-(uint8_t*)getVPlane;

-(void)initWithSize:(CGSize)szTexture;
-(void)allocYUVMem;
-(BOOL)getAsMemHolder;
-(void)setDirtyFlag:(BOOL)flag;
-(BOOL)getDirtyFlag;
@end
//
//@protocol IGLiveGLTexturePixelBuffer <IGLiveGLTexture>
//@required
//-(void)initWithTextureCache:(CVPixelBufferRef) textureCache;
//-(void)setTextureCache:(CVPixelBufferRef)textureCache;
//-(CVPixelBufferRef)getTextureCache;
//@end
