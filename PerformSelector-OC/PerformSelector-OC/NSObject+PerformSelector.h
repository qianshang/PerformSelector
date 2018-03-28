//
//  NSObject+PerformSelector.h
//  PerformSelector-OC
//
//  Created by mac on 2018/3/28.
//  Copyright © 2018年 程维. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformSelector)

- (void)ps_performSelector:(SEL)aSelector onThread:(NSThread *)thr waitUntilDone:(BOOL)wait withObjects:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;

- (id)ps_performSelector:(SEL)aSelector withObjects:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;

@end
