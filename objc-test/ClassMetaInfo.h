#import <Foundation/Foundation.h>

@interface FalcoObjectParent : NSObject
+(NSString*)FalcoObjectParentDesc;
-(NSString*)getDebugInfo;
@end

@interface FalcoObjectInfo : FalcoObjectParent
@property(retain, nonatomic) NSString* name;  //接口name
@property(retain, nonatomic) NSString* comid; //组件名
@property(retain, nonatomic) NSString* clsid; //类名
@property(retain, nonatomic) NSString* iid;   //接口guid
@property(retain, nonatomic) NSString* type;  //service or object
@property(retain, nonatomic) Class clsClass;
+(NSString*)FalcoObjectInfoDesc;
@end
