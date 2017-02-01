//
//  ThreeViewController.m
//  RAC_2
//
//  Created by 叶杨杨 on 2017/2/2.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 聚合信号
- (void)combineLatest{
    
    RACSignal *combineSignal = [[RACSignal combineLatest:@[self.accountField.rac_textSignal,self.pwdField.rac_textSignal]] reduceEach:^id(NSString *account, NSString *pwd){ //reduce里的参数一定要和combineLatest数组里的一一对应。  {
        //reduce里的参数一定要和combinelatest数组的一一对应
        return @(account.length && pwd.length);
    }];
    
//    [combineSignal subscribeNext:^(id x) {
//        self.loginBtn.enabled = [x boolValue];
//    }];
    
    RAC(self.loginBtn,enabled) = combineSignal;
}

#pragma mark - zip压缩信号
- (void)zipWith{
    //把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并把两个信号的内容合并成一个元组，才会触发压缩流的next事件
    RACSubject *signal1 = [RACSubject subject];
    RACSubject *signal2 = [RACSubject subject];
    
    RACSignal *zipSignal = [signal1 zipWith:signal2];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);//所有的值都被包装成了元组
    }];
    
    [signal1 sendNext:@1];
    [signal2 sendNext:@2];
}

#pragma mark - merge信号
//多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge{
    
    RACSubject *signal1 = [RACSubject subject];
    RACSubject *signal2 = [RACSubject subject];
    RACSignal *mergeSignal = [RACSignal merge:@[signal1,signal2]];
    [mergeSignal subscribeNext:^(id x) {
        
    }];
    
    [signal1 sendNext:@"1"];
    [signal2 sendNext:@"2"];
}

#pragma mark - then
// 有两部分数据：想让上部分数据先进行网络请求但是过滤掉数据，之后进行下部分的请求，拿到下部分的数据
- (void)then{
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"上部分的afn的数据"];
        [subscriber sendCompleted];//必须调用完成
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"下部分的afn的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //创建组合信号
    //then会忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signal1 then:^RACSignal *{
       
        return signal2;
    }];
    
    //订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - concat 组合
// 有两部分数据，想让上部分先执行，完了之后再执行下部分(都可以获取值)

- (void)concat{
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted];//必须调用
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
                          
    //concat 第一个信号必须调用completed
    RACSignal *concatSignal = [signal1 concat:signal2];
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}







@end
