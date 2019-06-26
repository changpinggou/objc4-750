#import "ClassMetaInfo.h"

@implementation FalcoObjectParent
+(NSString*)FalcoObjectParentDesc
{
    return @"FalcoObjectParentDesc";
}

-(NSString*)getDebugInfo
{
    return @"getDebugInfo";
}
@end

@interface FalcoObjectInfo()
{
    int _a;
    int _b;
}
@end

@implementation FalcoObjectInfo
+(NSString*)FalcoObjectInfoDesc
{
    return @"FalcoObjectInfoDesc";
}

-(instancetype)init
{
    if (self = [super init]) {
        _a = 10;
        _b = 20;
    }
    return self;
}
@end
