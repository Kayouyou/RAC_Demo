//
//  ViewController.m
//  RAC_2
//
//  Created by 叶杨杨 on 2017/1/31.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
//关于RAC的一些小知识点

@interface ViewController ()<UITextFieldDelegate,UIScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/***** 第一 基础部分 *****/
#pragma mark - textfield属性变化

- (void)textFieldChange{
    
    UITextField *textField = ({
        UITextField *tetxField = [[UITextField alloc] init];
        textField.backgroundColor = [UIColor darkGrayColor];
        tetxField;
    });
    
    textField.delegate = self;
    [self.view addSubview:textField];
    @weakify(self);
    
    /**
     RAC内部封装的类，文本内容变化就会执行block内部的代码块
     @param x 文本框内容
     */
    [textField.rac_textSignal subscribeNext:^(id x) {
        //@strongify(self);
        NSLog(@"输入框x的值 %@",x);
    }];
}

#pragma mark - button点击事件监听
- (void)buttonClicked{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"RAC点击" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    @weakify(self);
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"点击了button");
    }];
}

#pragma mark - 手势事件
- (void)tapGestureEvent{
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"手势事件触发");
    }];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - 通知中心
- (void)notifierEvent{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"notifyName" object:nil] subscribeNext:^(id x) {
       
    }];
}

#pragma mark - 代理
- (void)delegateEvent{
    
    UIAlertView*alert  = [[UIAlertView alloc] initWithTitle:@"RAC_ALERT" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"sure", nil];
    [alert show];
    //第一种方式
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(id x) {
      //返回的是RACTuple
        RACTuple *tuple = (RACTuple *)x;
        NSLog(@"%@ %@",tuple.first,tuple.second);
    }];
    //第二种方式
    [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
       
        
    }];
}

#pragma mark - KVO 事件
- (void)KVOEvent{
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    [RACObserve(scrollView, contentOffset) subscribeNext:^(id x) {
        NSLog(@"scrollView的偏移量 %@",x);
    }];
}

#pragma mark - 多次请求都获取到数据时才能更细UI界面
- (void)requestManyTimes{
    RACSignal *requestOne = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"发送请求1的数据"];
        return nil;
    }];
    RACSignal *requestTwo = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [subscriber sendNext:@"发送请求2的数据"];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(updateUI) withSignals:@[requestOne,requestTwo]];
}

#pragma mark - 更新UI

- (void)updateUI{
    NSLog(@"处理跟新UI界面触发");
}

#pragma mark - 定时器
- (void)RACTimer{
    
    //延时2秒执行block
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        
    }];
    //间隔1秒中执行一次block
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
       
    }];
}

/***** 第二 核心类使用 *****/
/**
 
 RACSignal使用步骤：
 1，创建信号 + (RACSignal *)createSignal......
 2，订阅信号，才会激活信号，-(RACDisposable *)subscribeNext:......
 3，发送信号 -(void)sendNext:(id)value......
 
 RACSignal底层实现：
 1，创建信号，首先把didSubscrible保存到信号中，还不会触发
 2，当信号被订阅，也就是调用signal的subscribleNext:nextBlock
 3，subscriblrNext内部会创建订阅者subscribler,并且把nextBlock 保存在subscribler中
 4，subscribler内部会调用signal的didSubscrible
 5，signal的didSubscrible中调用subscribler endNext:@1...
 6，sendNext底层就是执行subscribler的nextBlock

 */

- (void)baseClassRACSignal{
   
    //1， 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        //block调用时刻，每当有订阅者订阅信号，就会调用block
        //发送信号
        [subscriber sendNext:@"AFN_Data"];
        [subscriber sendCompleted];
        
        /**
         取消信号：如果信号想要被取消，就必须返回一个racdisposable
         信号什么时候被取消：1，自动取消，当一个信号的订阅者被销毁的时候，会自动取消订阅
                         2，手动取消，
         
         block什么时候调用，一旦一个信号被取消订阅就会调用
         block的作用：当信号被销毁的时候用于清空一些资源
         */
        return [RACDisposable disposableWithBlock:^{

            //block的调用时刻：当信号发送完成或者发送错误，就会自动执行这个block，取消订阅信号
        }];
        
    }];
    
    //2，订阅信号
    /**
     subscribleNext 把nextblock保存到订阅者里面
     只要订阅信号就会返回一个取消订阅信号的类
     */
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
       //block的调用时刻，每当有信号发出数据的时候们就会调用block
        
    }];
    
    //取消订阅
    [disposable dispose];
}

/***** 第二 RACSubject使用 *****/
/**
 
 RACSubject介绍：它既是信号提供者，本身也是信号，可以发送信号。
 
 使用场景：通常用来代替代理，有了它就不必定义代理了
 
 需求：
 1，给当前的控制器添加一个按钮，push到另外一个控制器界面
 2，另外一个控制器view中有个按钮，点击按钮，返回控制器的第一个界面并接受第二个界面的数据
 */


/**
 模拟页面一
 */

- (void)viewOneMethod{
    
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        TwoViewController *twovc = [TwoViewController new];
        //创建信号
        twovc.subject = [RACSubject subject];
        //订阅信号
        [twovc.subject subscribeNext:^(id x) {//这里的x既是sendNext发来的信号
            NSLog(@"视图控制器二传回的数据 %@",x);
        }];
        [self.navigationController pushViewController:twovc animated:YES];
    }];
    
    /**
     RACSubject和RACReplaySubject的区别
     前者必须先订阅之后才可以发送信号，而后者可以先发信号在订阅
    
     RACSubject:底层实现和RACSignal不一样
     1，调用subscribleNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了
     2，调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个个调用订阅者的nextBlock;
     */
    
}









@end
