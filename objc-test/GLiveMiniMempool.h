#import <Foundation/Foundation.h>

@interface GLiveMiniMempool : NSObject
+ (instancetype)shareInstance;
- (uint8_t*)mallocSpaceWithSize:(size_t)szMem;
- (void)freeSpaceWithSize:(size_t)szMem memPtr:(uint8_t*)pMem;
@end
