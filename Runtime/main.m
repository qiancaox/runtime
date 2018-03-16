//
//  main.m
//  Runtime
//
//  Created by qiancaox on 2018/3/16.
//  Copyright © 2018年 qiancaox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface ForwardingClass : NSObject

- (void)notDefinedMehtod;

@end

@implementation ForwardingClass

- (void)notDefinedMehtod
{
    NSLog(@"not defined mehtod, then add method");
}

@end

@interface RuntimeTestClass : NSObject

+ (void)shoutUp;
- (NSArray *)shout;

@end

@implementation RuntimeTestClass

void notDefinedMehtod() {
    NSLog(@"not defined mehtod, then add method");
}

- (NSArray *)shout
{
    NSLog(@"Please help me!");
    return nil;
}

+ (void)shoutUp
{
}

#pragma mark - 3

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    ForwardingClass *surrogate = [ForwardingClass new];
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [surrogate methodSignatureForSelector:selector];
    }
    return signature;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    ForwardingClass *forward = [ForwardingClass new];
    if ([forward respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:forward];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
}

#pragma mark - 2

//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    if (aSelector == @selector(notDefinedMehtod)) {
//        return [ForwardingClass new];
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

#pragma mark - 1

//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    if (sel == @selector(notDefinedMehtod)) {
//        class_addMethod([self class], sel, (IMP)notDefinedMehtod, "v");
//        return YES;
//    }
//
//    return [super resolveInstanceMethod:sel];
//}
//+ (BOOL)resolveClassMethod:(SEL)sel
//{
//
//}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        RuntimeTestClass *instance = [[RuntimeTestClass alloc] init];
        Class class = object_getClass(instance); // RuntimeTestClass类，通过object_getClass获取isa，和RuntimeTestClass.class结果一致
        Class metaClass = object_getClass(class); // 因为上面的class已经是一个类对象了，既然它是一个对象，那么他的isa指针也是通过object_getClass来获取，然而此时的isa是指向元类对象的，这里比较绕，多理解
        Class superClass = class_getSuperclass(class); // 获取class的父类，此时应该获取到NSObject
        Class metaClassSuperClass = class_getSuperclass(metaClass); // 获取元类的父类，此时获取到了根元类，应该为NSObject
        Class metaClassMetaClass = object_getClass(metaClass); // 获取元类的元类，此时也获取到了根元类，应该为NSObject
        Class metaClassMetaClassSuperClass = class_getSuperclass(metaClassMetaClass); // 获取元类的元类的父类，根元类的super_class指向根类，也是NSObject
        
//        NSLog(@"class = %@ %p", class, class);
//        NSLog(@"metaClass = %@ %p", metaClass, metaClass);
//        NSLog(@"superClass = %@", superClass);
//        NSLog(@"metaClassSuperClass = %@", metaClassSuperClass);
//        NSLog(@"metaClassMetaClass = %@", metaClassMetaClass);
//        NSLog(@"metaClassMetaClassSuperClass = %@", metaClassMetaClassSuperClass);
        // 获取class的实例方法
        unsigned int class_methods_list_count = 0;
        Method* meths = class_copyMethodList(class, &class_methods_list_count);
        for (int i = 0; i < class_methods_list_count; i++) {
            Method meth = meths[i];
            SEL sel = method_getName(meth);
            const char *name = sel_getName(sel);
            NSLog(@"%s", method_getTypeEncoding(meth));
            NSLog(@"%s", name);
        }
        free(meths);
        NSLog(@"---------------------------------------------------------");
        // 获取metaClass的实例方法
        unsigned int meta_class_methods_list_count = 0;
        Method* meta_meths = class_copyMethodList(metaClass, &meta_class_methods_list_count);
        for (int i = 0; i < meta_class_methods_list_count; i++) {
            Method meth = meta_meths[i];
            SEL sel = method_getName(meth);
            const char *name = sel_getName(sel);
            NSLog(@"%s", method_getTypeEncoding(meth));
            NSLog(@"%s", name);
        }
        free(meta_meths);
        
        [instance performSelector:@selector(notDefinedMehtod)];
    }
    return 0;
}


