//
//  NSObject+PerformSelector.m
//  PerformSelector-OC
//
//  Created by mac on 2018/3/28.
//  Copyright © 2018年 程维. All rights reserved.
//

#import "NSObject+PerformSelector.h"

@implementation NSObject (PerformSelector)

NSArray * arrayWith(va_list args, id arg) {
    NSMutableArray *argsArray = [NSMutableArray arrayWithCapacity:0];
    [argsArray addObject:arg];
    id obj;
    while((obj = va_arg(args, id))) {
        [argsArray addObject:obj];
    }
    return argsArray;
}

- (void)ps_performSelector:(SEL)aSelector onThread:(NSThread *)thr waitUntilDone:(BOOL)wait withObjects:(id)arg, ... {
    NSArray *argsArray = nil;
    if (arg) {
        va_list args;
        va_start(args, arg);
        argsArray = arrayWith(args, arg);
        va_end(args);
    }
    NSInvocation *invo = [self invocationFrolSelector:aSelector withObjects:argsArray];
    
    [invo retainArguments];
    
    [invo performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:NO];
}

- (id)ps_performSelector:(SEL)aSelector withObjects:(id)arg, ... {
    NSArray *argsArray = nil;
    if (arg) {
        va_list args;
        va_start(args, arg);
        argsArray = arrayWith(args, arg);
        va_end(args);
    }
    
    NSInvocation *invo = [self invocationFrolSelector:aSelector withObjects:argsArray];
    if (!invo) {
        return nil;
    }
    [invo invoke];
    
    id result = nil;
    NSMethodSignature *sign = [self methodSignatureForSelector:aSelector];
    if (sign.methodReturnLength) {
        [invo getReturnValue:&result];
    }
    return result;
}


- (NSInvocation *)invocationFrolSelector:(SEL)aSelector withObjects:(NSArray *)args {
    NSMethodSignature *sign = [self methodSignatureForSelector:aSelector];
    
    if (!sign) {
        NSLog(@"(%@) method is not found from (%@)", NSStringFromSelector(aSelector), NSStringFromClass([self class]));
        return nil;
    }
    
    NSUInteger number = sign.numberOfArguments;
    NSInteger count = MIN(args.count, number - 2);
    
    NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sign];
    [invo setTarget:self];
    [invo setSelector:aSelector];
    
    for (NSInteger i = 0; i < count; i ++) {
        id arg = args[i];
        [invo setArgument:&arg atIndex:i + 2];
    }
    return invo;
}

@end
