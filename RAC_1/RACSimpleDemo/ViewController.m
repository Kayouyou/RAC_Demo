//
//  ViewController.m
//  RACSimpleDemo
//
//  Created by 叶杨杨 on 2017/1/25.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h> 

@interface ViewController ()
@property (nonatomic, assign) BOOL passwordIsValid;
@property (nonatomic, assign) BOOL usernameIsValid;
@property (nonatomic, assign) BOOL signInValid;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUIState];
    [self.userName_text addTarget:self action:@selector(usernameTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passWord_text addTarget:self action:@selector(passwordTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    //RAC 有三种信号 next error completed 一个signal 因error终结前可以发送任意数量的next事件
    // rac_textSignal 是RAC框架通过category为很多基本UIKit控件添加signal，这样你的控件就添加了订阅。
    //1,第一种写法
    [[self.userName_text.rac_textSignal
     
     filter:^BOOL(id value) {//过滤
         NSString *text = value;
         return text.length > 3;
     }]
     subscribeNext:^(id x) {//订阅信号
        
        NSLog(@"用户名输入框 %@",x);
     }];
    //2,第二种写法
    //RAC的每个操作都会返回一个RACSignal的信号，这叫连贯接口，你不用每一步使用本地变量
    RACSignal *usernamesignal = self.userName_text.rac_textSignal;
    RACSignal *filterUsername = [usernamesignal filter:^BOOL(id value) {
        NSString *text = value;
        return  text.length > 3;
    }];
    
    [filterUsername subscribeNext:^(id x) {
        NSLog(@"用户名输入框 %@",x);
    }];
    
    
}

- (void)usernameTextFieldChanged{
    self.usernameIsValid = [self isValidUserName:self.userName_text.text];
    [self updateUIState];
}

- (void)passwordTextFieldChanged{
    self.passwordIsValid = [self isValidPassWord:self.passWord_text.text];
    [self updateUIState];
}

- (IBAction)signInBtnClicked:(UIButton *)sender {


}

- (void)updateUIState{
    self.userName_text.backgroundColor = self.passwordIsValid ? [UIColor clearColor] : [UIColor yellowColor];
    self.passWord_text.backgroundColor = self.usernameIsValid ? [UIColor clearColor] : [UIColor yellowColor];
    self.signInButton.enabled = self.usernameIsValid && self.passwordIsValid;
}

- (BOOL)isValidUserName:(NSString *)username{

    return username.length > 3;
}

- (BOOL)isValidPassWord:(NSString *)password{
    
    return password.length > 3;
}












@end
