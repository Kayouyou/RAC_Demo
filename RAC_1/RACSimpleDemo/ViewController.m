//
//  ViewController.m
//  RACSimpleDemo
//
//  Created by 叶杨杨 on 2017/1/25.
//  Copyright © 2017年 叶杨杨. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h> 
#import "RWDummySignInService.h"//模拟HTTP请求类

@interface ViewController ()

@property (nonatomic, assign) BOOL signInValid;
@property (nonatomic, strong) RWDummySignInService *signinService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.signinService = [RWDummySignInService new];
    //通过RAC重构项目
    //第一步
     RACSignal *validUsernameSignal = [self.userName_text.rac_textSignal map:^id(NSString * text) {
         return @([self isValidUserName:text]);
     }];
    RACSignal *validPasswordSignal = [self.passWord_text.rac_textSignal map:^id(NSString *text) {
        return @([self isValidPassWord:text]);
    }];
    
    //第二步
    /**
    [[validUsernameSignal map:^id(NSNumber *usernameValid) {
       
        return [usernameValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
    }]
    subscribeNext:^(UIColor *color) {

        self.userName_text.backgroundColor = color;
    }];
    */
    //但是上述的用法不是很好，我们可以再次精简
    
    RAC(self.userName_text,backgroundColor) = [validUsernameSignal map:^id(NSNumber *usernameValid) {
        return [usernameValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
    }];
    
    RAC(self.passWord_text,backgroundColor) = [validPasswordSignal map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
    }];

    // 聚合信号，登录按钮只有当用户名和密码输入框的输入都有效时才工作。现在要把这里改成响应式的。
    //每次产生一个新的值时，reduce block 都会执行，block的返回值会发给下一个信号。
    RACSignal *signalActiveSignal = [RACSignal combineLatest:@[validUsernameSignal,validPasswordSignal] reduce:^id(NSNumber*usernameValid, NSNumber *passwordValid){
        return @([usernameValid boolValue]&&[passwordValid boolValue]);
    }];
   
    [signalActiveSignal subscribeNext:^(NSNumber*signupActive) {
       
        self.signInButton.enabled = [signupActive boolValue];
        
    }];
    
    // rac信号的rac_signalForControlEvents，用于事件
    [[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     
      //处理信号中的信号,这个操作把按钮点击事件转换为登录信号，同时还从内部信号发送事件到外部信号。
     flattenMap:^RACStream *(id value) {
       
         return [self signinSignal];//内部信号，向外部发送信号，所以使用flattenMap函数
     }]
     subscribeNext:^(NSNumber*signedIn) {
       
         BOOL success = [signedIn boolValue];
         if (success) {
             
             NSLog(@"登陆成功");
         }else{
             
             NSLog(@"登陆失败");
         }
        
    }];
    
    
    
    
    
    
    
    
    //RAC 有三种信号 next error completed 一个signal 因error终结前可以发送任意数量的next事件
    // rac_textSignal 是RAC框架通过category为很多基本UIKit控件添加signal，这样你的控件就添加了订阅。
    //1,第一种写法
    /**
    [[self.userName_text.rac_textSignal
     
     filter:^BOOL(NSString * text) {//过滤
         
         return text.length > 3;
     }]
     subscribeNext:^(id x) {//订阅信号
        
        NSLog(@"用户名输入框 %@",x);
     }];
     */
    //2,第二种写法
    //RAC的每个操作都会返回一个RACSignal的信号，这叫连贯接口，你不用每一步使用本地变量
    /**
    RACSignal *usernamesignal = self.userName_text.rac_textSignal;
    RACSignal *filterUsername = [usernamesignal filter:^BOOL(id value) {
        NSString *text = value;
        return  text.length > 3;
    }];
    
    [filterUsername subscribeNext:^(id x) {
        NSLog(@"用户名输入框 %@",x);
    }];
    */
    
    //3,map转换函数
    /**
    [[[self.userName_text.rac_textSignal map:^id(NSString * text) {
        
        return @(text.length);
    }]
    
    filter:^BOOL(NSNumber *length) {
        
        return [length integerValue] > 3;
    }]
    
    subscribeNext:^(id x) {
        
        NSLog(@"用户名输入框%@",x);
    }];
    */
    
    
}

#pragma mark - 创建信号

- (RACSignal *)signinSignal{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [self.signinService
         signInWithUsername:self.userName_text.text
         password:self.passWord_text.text
         complete:^(BOOL success){
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}



- (BOOL)isValidUserName:(NSString *)username{

    return username.length > 3;
}

- (BOOL)isValidPassWord:(NSString *)password{
    
    return password.length > 3;
}












@end
