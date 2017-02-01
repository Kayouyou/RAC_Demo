//
//  ViewController.m
//  RAC_2
//
//  Created by 叶杨杨 on 2017/1/31.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
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






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
