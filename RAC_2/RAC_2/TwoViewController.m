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

//正常用法
- (void)normalCommand{
    //1，创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就胡调用
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           
            [subscriber sendNext:@"AFN_Data"];
            return nil;
        }];
    }];
    
    /**
     如何拿到执行命令中产生的数据呢？
     订阅命令内部的信号
     方式一：直接订阅执行命令返回的信号
     */

    //2，执行命令
    RACSignal *signal = [command execute:@1];
    //3,订阅信号
    [signal subscribeNext:^(id x) {
        
    }];
}

// 一般的用法
- (void)generalMethod{
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //input为传进来的参数
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"AFN_Data"];
            return nil;
            
        }];
    }];
    
    /**
     方式二：必须先订阅才能发送命令
     executionSignals :信号源，信号中的信号，
     */
    [command.executionSignals subscribeNext:^(id x) {
       
        [x subscribeNext:^(id x) {
            
       }];
        
    }];
    
    [command execute:@2];
}

//高级用法

- (void)lessLowerMethod{
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"发送afn数据"];
            return nil;
        }];
    }];
    /**
     方式三：switchToLatest 获取最新发送的信号，只能用于信号中的信号
     
     */
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
    }];
    
    //执行命令
    [command execute:@3];
}

//监听事件有没有完成
/**
 RACCommand 通常用来表示某个action的执行，比如点击button，它有几个比较重要的属性
 executionSignals/ errors /executing
 
 1，executionSignals 是信号中的信号，如果直接subscrible的话会得到一个signal，而不是我们想要的value，所以一般配合switchToLatest。
 2，errors 跟正常的signal不一样，RACCommand的错误不是通过sendError实现的，而是通过errors的属性传递的
 3，executing 表示该command当前是否正在执行
 */
- (void)monitorIsCompleted{
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"afnData"];
            
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [command.executing subscribeNext:^(id x) {
       
        if ([x boolValue]) {//正在执行
            
            
        }else{//执行完毕，或还未执行
            
        }
    }];
    
    //执行命令
    [command execute:@4];
}

/***** 第四 RACMulticastConnection的使用 *****/

/**
 RACMulticastConnection：用于当一个信号被多次的订阅时，为了保证信号创建的时被多次的调用创建信号中的block，造成副作用，可以使用这个类处理。
 
 使用注意：它是通过RACSignal的publish或者muticast方法创建的
 
 使用步骤：
 1，创建信号
 2，创建链接 RACMulticastConnection *connect = [signal publish]
 3，订阅信号，注意订阅的不在是之前的信号，而是链接的信号。[cpnnect.signal subscribeNext]
 4，链接 [connect connect]
 
 RACMulticastConnection 底层的原理
 1,创建connect，connect.sourceSignal ->RACSignal（原始信号）connect.signal -> RACSubject
 2，订阅connect.signal，会调用RACSubejct的subscribeNext，创建订阅者，而且吧订阅者保存起来而不会执行block
 3，【connect sonnect】内部会订阅RACSignal（原始信号）
 4，订阅原始信号，就会调用原始信号中的didSubscibe
 5，didSubscribe，拿到订阅者调用sendNext 其实是调用RACSubeject的sendNext
 6，RACSubject的sendNext会遍历RACSubejct的所有订阅者发送信号
 7，因为刚刚第二步，都在订阅RACSubject，因此会拿到第二步的所有订阅者，调用他们的nextBlock
 
 */

- (void)sendNextManyTimes{
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"afn"];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        
    }];
    [signal subscribeNext:^(id x) {
        
    }];
    [signal subscribeNext:^(id x) {
        
    }];
    
    //上面的做法不太好，应该是无论有多少个只发送一个
    // 比较好的做法 创建链接类
    RACMulticastConnection *connection = [signal publish];
    
    [connection.signal subscribeNext:^(id x) {
        
    }];
    [connection.signal subscribeNext:^(id x) {
        
    }];
    [connection.signal subscribeNext:^(id x) {
        
    }];
    
    //连接，只有链接才会把信号源变为热信号
    [connection connect];
}

#pragma mark - 映射

- (void)map{
    
    /**
     map 的使用步骤：
     1，传入一个block，类型是返回对象，参数是value
     2，value就是源信号的内容，直接拿到源信号的内容做处理
     3，把处理好的内容直接返回就好了，不用包装成信号，返回的值，就是映射的值
     
     map的底层实现：
     1，map的底层其实是调用faltternMap，map中block的返回值会作为flatternMap的中的block的值
     2，当订阅绑定信号，就会生成bindBlock
     3，当源信号发送内容，就会调用bindBlock（value，*stop）
     4，调用bindBlock，内部就会调用faltternMap的block
     5，faltternMap的block内部救护调用map中的block，把map的block返回的内容包装成返回的信号
     6，返回的信号最终会作为bindBlock中的返回信号，当做bindblock的返回信号
     7，订阅bindBlock的返回信号就会拿绑定信号的订阅者，把处理完成的信号发送过来
     
     map的作用就是把源信号的值映射成一个新的值
     */
    
    //创建信号
    RACSubject *subject = [RACSubject subject];
    //绑定信号
    RACSignal *signal = [subject map:^id(id value) {
       
        return [NSString stringWithFormat:@"ws:%@",value];
    }];
    //订阅绑定信号
    [signal subscribeNext:^(id x) {
        
    }];
    
    //发送信号
    [subject sendNext:@"123"];
}

/**
 flatternMap 与 Map的区别
 1,前者中的block返回信号
 2，后者中的block返回对象
 3，开发中如果信号发出的值不是信号，映射一般使用map
 4，开发中如果信号发出的值是信号，映射一般使用flatternMap

 */

- (void)faltternMap{
    
    RACSubject *subject  = [RACSubject subject];
    
    RACSignal *signal = [subject flattenMap:^RACStream *(id value) {
       
        return value;
    }];
    
    [signal subscribeNext:^(id x) {
        
    }];
    
    [subject sendNext:@"123456"];
    
}









@end
