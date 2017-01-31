//
//  ViewController.m
//  RAC_2
//
//  Created by 叶杨杨 on 2017/1/31.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
//关于RAC的一些小知识点

@interface ViewController ()<UITextFieldDelegate>

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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
