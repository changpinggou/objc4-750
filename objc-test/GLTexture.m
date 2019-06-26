#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#define __FILE__ "GLTexture.m"
#pragma clang diagnostic pop
#import <objc/runtime.h>
#import <objc/message.h>
#import "GLTexture.h"
#import "GLiveMiniMempool.h"

@implementation MyTestClass
-(void)MyFunc
{
    NSLog(@"self ptr:%@, className:%@", self, self.className);
    NSLog(@"call MyFunc");
}

@end
@implementation GLTexture
- (int)getHeight {
    return _height;
}
- (void)setHeight:(int)height {
    _height = height;
}
- (int)getWidth {
    return _width;
}
- (void)setWidth:(int)width {
    _width =width;
}
- (CGFloat)getZRotateAngle {
    return _zRotateAngle;
}
- (void)setZRotateAngle:(CGFloat)angle {
    _zRotateAngle = angle;
}
- (void)deleteTexture{
}

+ (void)testIGLiveGLTexture
{
    NSLog(@"call class method:testIGLiveGLTexture");
}
@synthesize flag;

@end

@implementation GLTextureYUV
{
    size_t _szYPlane;
    size_t _szUPlane;
    size_t _szVPlane;
    BOOL _memAllocHolder; //为了做一点内存性能优化，复杂！
    BOOL _dirtyFlag;
}

- (void)initWithSize:(CGSize)szTexture
{
    self.flag = 10;
    self.zRotateAngle = 0;
    self.width = szTexture.width;
    self.height = szTexture.height;
    _szYPlane = szTexture.width * szTexture.height;
    _szUPlane = _szYPlane/4;
    _szVPlane = _szYPlane/4;
    _memAllocHolder = NO;
    _dirtyFlag = NO;

    _Y = NULL;
    _U = NULL;
    _V = NULL;
}

-(void)setDirtyFlag:(BOOL)flag
{
    _dirtyFlag = flag;
}

-(BOOL)getDirtyFlag
{
    return _dirtyFlag;
}

-(void)allocYUVMem
{
    //该函数只能调用一次
    if (_memAllocHolder == YES) {
        return;
    }
    
    _memAllocHolder = YES;
    _Y = [[GLiveMiniMempool shareInstance] mallocSpaceWithSize:_szYPlane];
    _U = [[GLiveMiniMempool shareInstance] mallocSpaceWithSize:_szUPlane];
    _V = [[GLiveMiniMempool shareInstance] mallocSpaceWithSize:_szVPlane];
}

-(BOOL)getAsMemHolder
{
    return _memAllocHolder;
}

-(void)dealloc
{
    [self deleteTexture];
}

- (void)deleteTexture
{
    if (_memAllocHolder) {
        if (_szYPlane != 0) {
            [[GLiveMiniMempool shareInstance] freeSpaceWithSize:_szYPlane memPtr: _Y];
            _Y = NULL;
        }
        
        if (_szUPlane != 0) {
            [[GLiveMiniMempool shareInstance] freeSpaceWithSize:_szUPlane memPtr: _U];
            _U = NULL;
        }
        
        if (_szVPlane != 0) {
            [[GLiveMiniMempool shareInstance] freeSpaceWithSize:_szVPlane memPtr: _V];
            _V = NULL;
        }
        
    }
    else
    {
        _Y = NULL;
        _U = NULL;
        _V = NULL;
    }
}

-(void)setYPlane:(uint8_t*)Y
{
    _Y = Y;
}
-(uint8_t*)getYPlane
{
    return _Y;
}

-(void)setUPlane:(uint8_t*)U
{
    _U = U;
}
-(uint8_t*)getUPlane
{
    return _U;
}

-(void)setVPlane:(uint8_t*)V
{
    _V = V;
}
-(uint8_t*)getVPlane
{
    return _V;
}
@end
