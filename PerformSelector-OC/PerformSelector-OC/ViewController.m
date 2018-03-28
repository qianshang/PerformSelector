//
//  ViewController.m
//  PerformSelector-OC
//
//  Created by mac on 2018/3/28.
//  Copyright © 2018年 程维. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+PerformSelector.h"
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self ps_performSelector:@selector(testFirst:second:third:) onThread:[NSThread mainThread] withObjects:@[@"A", @"B", @"C"] waitUntilDone:NO];
    
    [self ps_performSelector:@selector(testFirst:second:third:) onThread:[NSThread mainThread] withObjects:@[@"A", @"B"] waitUntilDone:NO];
    
    [self ps_performSelector:@selector(testFirst:second:third:) withObjects:@[@"F", @"E", @"D"]];
    
    
    SEL sel = @selector(testFirst:second:third:);
    
    ((void (*) (id, SEL, NSString *, NSString *, NSString *)) objc_msgSend) (self, sel, @"AA", @"BB", @"CC");
}

- (void)testFirst:(NSString *)argA second:(NSString *)argB third:(NSString *)argC {
    NSLog(@"当前线程:%@", [NSThread currentThread]);
    NSLog(@"first:%@ - second:%@ - third:%@", argA, argB, argC);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
