# PerformSelector
PerformSelector参数扩展

在iOS开发中，我们可以使用使用`performSelector`来调用方法，但是受限与以下方法，我们想要传递参数的话也就只能传递一个两个或者不传。

```
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
	// equivalent to the first method with kCFRunLoopCommonModes

- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
	// equivalent to the first method with kCFRunLoopCommonModes
- (void)performSelectorInBackground:(SEL)aSelector withObject:(nullable id)arg API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
```


所以为了实现多个参数的传递，我们可以使用以下方法：

```
// 下面的例子都是基于这个方法
- (void)testFirst:(NSString *)argA second:(NSString *)argB third:(NSString *)argC {
    NSLog(@"当前线程:%@", [NSThread currentThread]);
    NSLog(@"first:%@ - second:%@ - third:%@", argA, argB, argC);
}
```

- 1. 将方法的多个参数包装成一个参数(如NSDictionary)

略

- 2. 使用`NSInvocation`

```
// 1. 获取方法签名
NSMethodSignature *sign = [self methodSignatureForSelector:aSelector];

// 2. 获取参数个数
NSUInteger number = sign.numberOfArguments;
NSInteger count = MIN(args.count, number - 2);

// 3. 利用NSInvocation对象对方法进行包装
NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sign];

// 3.1 设置方法调用者
[invo setTarget:self];
// 3.2 设置方法名
[invo setSelector:aSelector];
// 3.3 设置方法参数
for (NSInteger i = 0; i < count; i ++) {
    id arg = args[i];
    [invo setArgument:&arg atIndex:i + 2];
}

// 4. 方法调用
[invo invoke];
```

此处，我是创建了一个`NSObject`的`Category`,暴露一下方法给调用者

```
- (void)ps_performSelector:(SEL)aSelector onThread:(NSThread *)thr waitUntilDone:(BOOL)wait withObjects:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;

- (id)ps_performSelector:(SEL)aSelector withObjects:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;
```

具体使用如下：

```
[self ps_performSelector:@selector(testFirst:second:third:) withObjects:@"AA", @"BB", @"CC", nil];

[self ps_performSelector:@selector(testFirst:second:third:) withObjects:@"E", @"F", nil];
    
[self ps_performSelector:@selector(testFirst:second:third:) onThread:[NSThread mainThread] waitUntilDone:NO withObjects:@"A", @"B", @"C", nil];

// 输出结果如下
/**
当前线程:<NSThread: 0x60000007d500>{number = 1, name = main}
first:AA - second:BB - third:CC
当前线程:<NSThread: 0x60000007d500>{number = 1, name = main}
first:E - second:F - third:(null)
当前线程:<NSThread: 0x60000007d500>{number = 1, name = main}
first:A - second:B - third:C
*/
```

---

`performSelector`在最后也是使用`objc_msgSend`进行消息转发，这里也可以直接使用`objc_msgSend`进行转发

```
// 需要先引入#import <objc/message.h>

SEL sel = @selector(testFirst:second:third:);
    
((void (*) (id, SEL, NSString *, NSString *, NSString *)) objc_msgSend) (self, sel, @"AA", @"BB", @"CC");
    
```