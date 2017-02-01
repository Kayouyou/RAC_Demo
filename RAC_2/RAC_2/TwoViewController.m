//
//  TwoViewController.m
//  RAC_2
//
//  Created by 叶杨杨 on 2017/2/1.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"返回信息" forState:UIControlStateNormal];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        //发送信号
        [self.subject sendNext:@"data"];
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

/***** 第三 RACCommand的使用 *****/

/**
 
 RACCommand的介绍：
 它用于处理事件的类，可以吧事件如何处理，事件中的数据如何传递，包装到这个类中，它可以很方便的监控事件的执行过程。
 使用场景是:监听按钮的点击，网络请求
 
 
 RACCommand简单使用:
 
 一 使用步骤：
 1，创建命令initwithSignalBlcok:
 2，在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
 3，执行命令 -(RACSignal*)execute:(id)input;
 
 
 二 使用注意：
 1，signalBlcok必须返回一个信号，不能传nil
 2，如果不想要传递信号，直接传递空的信号 [RACSignal empty];
 3，命令中的信号如果传递数据完成，必须调用【subscriber sendCompleted】,这时命令才算执行完毕，否则永远处于执行中；
 4，命令需要被强制的引用，否则接受不到命令中的信号，因此命令中的信号是延迟发送的；
 
 
 三 设计思想：为什么signalBlock会返回一个信号，这个信号的作用
 1，RAC开发中，通常会把网络请求放在command中，直接执行某个命令就能发送请求；
 2，当命令内部请求到数据的时候，需要把请求的数据传递给外界时，这个时候就需要通过signalBlcok中返回的信号去传递了
 
 
 四 如何拿到RACCommand中返回信号发出的数据：
 1，命令中有个信号数据源executionSignals ,这个是signal of signals (信号中的信号)，意思是信号发出的是信号不是普通的数据
 2,订阅executionsignlas就能拿到命令返回的信号，然后订阅signalBlock就能拿到返回的值了；
 
 
 五 监听当前命令是否正在执行executing
 
 */






@end
