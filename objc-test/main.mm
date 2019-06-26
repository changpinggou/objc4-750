//
//  main.m
//  objc-test
//
//  Created by GongCF on 2018/12/16.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "ClassMetaInfo.h"
#import "GLTexture.h"
#import "ClassMetaInfo+SearchExtend.h"
#import <algorithm>
#import <map>
#import <mutex>
#import <objc/runtime.h>
#import <unordered_map>
#import <unordered_set>
#import <vector>
#import "fishhook.h"
#import "CydiaSubstrate.h"

void TestObjClassHierarchy()
{
    Class newClass = objc_allocateClassPair(objc_getClass("NSObject"), "newClass", 0);
    objc_registerClassPair(newClass);
    id newObject = [[newClass alloc]init];
    NSLog(@"%@",newObject);
    FalcoObjectInfo* test1 = [[FalcoObjectInfo alloc]init];
    test1.name = @"FalcoObject";
    test1.comid = @"FalcoBaseComponent";
    Class FalcoObjClass = test1.class;
    Class FalcoParentClass = test1.superclass;
    Class FalcoObjMetaClass = objc_getMetaClass(test1.className.UTF8String);
    
    NSLog(@"%@", test1.name);
    NSLog(@"%@", test1.comid);
    CGSize size = CGSizeMake(100, 100);
    id<IGLiveGLTextureYUV> textureYUV = [[GLTextureYUV alloc] init];
    [textureYUV initWithSize:size];
    id<IGLiveGLTexture> texture = textureYUV;
    [textureYUV setHeight:347];
    [textureYUV setWidth:347];
    
    NSLog(@"texture Height:%d, Width:%d", [textureYUV getHeight], [textureYUV getWidth]);
    Protocol* testProtocol = @protocol(IGLiveGLTexture);
    Class temp = textureYUV.class;
    struct objc_class;
    objc_class* textureYUVClass =(__bridge objc_class*)temp;
    BOOL ret = class_addMethod(textureYUV.class, @selector(MyFunc), class_getMethodImplementation(MyTestClass.class, @selector(MyFunc)), "v@:");
    [textureYUV performSelector:@selector(MyFunc)];
    
    Class tempMeta = objc_getMetaClass(NSStringFromClass(temp).UTF8String);
    objc_class* textureYUVMetaClass =(__bridge objc_class*)tempMeta;
    ret = class_addMethod(tempMeta, @selector(MyFunc), class_getMethodImplementation(MyTestClass.class, @selector(MyFunc)), "v@:");
    [temp performSelector:@selector(MyFunc)];
    
    ret = class_addMethod(NSObject.class, @selector(MyFunc), class_getMethodImplementation(MyTestClass.class, @selector(MyFunc)), "v@:");
    [tempMeta performSelector:@selector(MyFunc)];
    
    NSLog(@"GLTextureYUV meta class:%@", tempMeta);
    //[GLTextureYUV testIGLiveGLTexture];
    Class metaClass = objc_getMetaClass("IGLiveGLTexture");
    
    //        objc_property
    //objc_pro
    //NSLog(@"IGLiveGLTexture property flag:%d", metaClass.flag);
    //[metaClass perform: @selector(testIGLiveGLTexture)];
    //look_up_clas
    
    
    Class FalcoObjectInfoClass = objc_lookUpClass("FalcoObjectInfo");
    
    ((void(*)(objc_class*, SEL))objc_msgSend)((__bridge objc_class*)metaClass, @selector(testIGLiveGLTexture));
    
    int flag = [textureYUV flag];
    NSLog(@"flag:%d", flag);
    
    
    
    if ([texture conformsToProtocol:testProtocol]) {
        NSLog(@"texture conformsToProtocol %@", @"[testProtocol description]");
    }
}

void TestObjClassCategory()
{
    FalcoObjectInfo* test1 = [[FalcoObjectInfo alloc]init];
    [test1 printDebugInfo];
}

static int (*orig_close)(int);
static int (*orig_open)(const char *, int, ...);

int my_close(int fd) {
    printf("Calling real close(%d)\n", fd);
    return orig_close(fd);
}

int my_open(const char *path, int oflag, ...) {
    va_list ap = {0};
    mode_t mode = 0;
    
    if ((oflag & O_CREAT) != 0) {
        // mode only applies to O_CREAT
        va_start(ap, oflag);
        mode = va_arg(ap, int);
        va_end(ap);
        printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
        return orig_open(path, oflag, mode);
    } else {
        printf("Calling real open('%s', %d)\n", path, oflag);
        return orig_open(path, oflag, mode);
    }
}



static Class (*orig_objc_getMetaClass)(const char *aClassName);

Class my_objc_getMetaClass(const char *aClassName) {
    printf("Calling my_objc_getMetaClass:%s\n", aClassName);
    return orig_objc_getMetaClass(aClassName);
}


//Class objc_lookUpClass(const char *aClassName)

static Class (*orig_objc_lookUpClass)(const char *aClassName);
Class my_objc_lookUpClass(const char *aClassName){
    printf("Calling my_look_up_class:%s\n", aClassName);
    return orig_objc_lookUpClass(aClassName);
}

static std::mutex *hookMutex(new std::mutex);

void hookLookupClass()
{
    
    MSHookFunction(&objc_lookUpClass, &my_objc_lookUpClass, &orig_objc_lookUpClass);
//    int result = rebind_symbols((struct rebinding[1]){
//        {
//            "objc_lookUpClass",
//            (void *)my_objc_lookUpClass,
//            (void **)&orig_objc_lookUpClass
//        }}, 1);
}

void hookGetMetaClass()
{
    int result = rebind_symbols((struct rebinding[1]){
        {
            "objc_getMetaClass",
            (void *)my_objc_getMetaClass,
            (void **)&orig_objc_getMetaClass
        }}, 1);
}

void hookCFunc(int argc, const char * argv[]){
    rebind_symbols((struct rebinding[2]){{"close", (void *)my_close, (void **)&orig_close}, {"open", (void *)my_open, (void **)&orig_open}}, 2);
    // Open our own binary and print out first 4 bytes (which is the same
    // for all Mach-O binaries on a given architecture)
    int fd = open(argv[0], O_RDONLY);
    uint32_t magic_number = 0;
    read(fd, &magic_number, 4);
    printf("Mach-O Magic Number: %x \n", magic_number);
    close(fd);
}
//void load_images(const char *path __unused, const struct mach_header *mh)
static void (*orig_load_images)(const char *path __unused, const struct mach_header *mh);
void my_load_images(const char *path __unused, const struct mach_header *mh)
{
    printf("Calling my_load_images:%s\n", path);
    orig_load_images(path, mh);
}

//void hookLoadImagesWithMS()
//{
//    MSHookFunction(&load_images, &my_load_images, &orig_load_images);
//}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        hookLookupClass();
        hookCFunc(argc, argv);
        hookGetMetaClass();
        TestObjClassHierarchy();
    }
    return 0;
}

