//
//  LoadFailedAlertView.m
//  CarApp
//
//  Created by 张三 on 2018/4/19.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "LoadFailedAlertView.h"
#import "UIColor+Util.h"
#import "UIView+frameAdjust.h"
#import "CarAppConstant.h"
#import "CarBundleTool.h"

@interface LoadFailedAlertView ()
/** 弹窗主内容view */
@property (nonatomic,strong) UIView   *contentView;
/** 弹窗标题 */
@property (nonatomic,copy)   NSString *title;
/** 弹窗message */
@property (nonatomic,copy)   NSString *message;
/** message label */
@property (nonatomic,strong) UILabel  *messageLabel;
/** 左边按钮title */
@property (nonatomic,copy)   NSString *leftButtonTitle;
/** 右边按钮title */
@property (nonatomic,copy)   NSString *rightButtonTitle;

@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation LoadFailedAlertView{
    UILabel *label;
}

#pragma mark - 构造方法
/**
 申报异常弹窗的构造方法
 @param title 弹窗标题
 @param message 弹窗message
 @param delegate 确定代理方
 @param leftButtonTitle 左边按钮的title
 @param rightButtonTitle 右边按钮的title
 @return 一个申报异常的弹窗
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate leftButtonTitle:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle{
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.leftButtonTitle = leftButtonTitle;
        self.rightButtonTitle = rightButtonTitle;
        
        // 接收键盘显示隐藏的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
        
        // UI搭建
        [self setUpUI];
    }
    return self;
}

#pragma mark - UI搭建
/** UI搭建 */
- (void)setUpUI{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    }];
    
    //设置背景
    UIImageView *bgImgView =  [[UIImageView alloc] initWithFrame:self.frame];
    //[bgImgView setImage:[UIImage imageNamed:@"bg_style_2"]];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];

    NSString *resName = @"bg_style_2";
    UIImage *image =  resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];
    [bgImgView setImage:image];
    [self addSubview:bgImgView];
    
    
    //------- 弹窗主内容 -------//
    self.contentView = [[UIView alloc]init];
    self.contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH/3*1.8, SCREEN_HEIGHT / 3*1.2);
    self.contentView.center = self.center;
    // self.contentView.x = self.centerX;
    
    //强行适配 ipone x 有问题啊
    if(KIsiPhoneX){
        self.contentView.centerY = self.centerY+12;
        
    }else{
        self.contentView.centerY = self.centerY+kStatusHeight/2;
    }
    [self addSubview:self.contentView];
    
    //阴影边框代码
    //  self.contentView.backgroundColor = [UIColor colorWithHexString:@"#09497b"];
    self.contentView.layer.cornerRadius = 6;
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    
    self.contentView.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    self.contentView.layer.shadowOpacity = 1;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    
    //提示内容信息
    self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.contentView.height/4, self.contentView.width, 22)];
    [self.contentView addSubview:self.messageLabel];
    self.messageLabel.font = [UIFont boldSystemFontOfSize:20];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    //    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.textColor = [UIColor colorWithHexString:@"#dee9f5"];
    self.messageLabel.text = @"内容加载失败，请检查当前网络...";
    
    //关闭按钮
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, self.contentView.height-self.contentView.height*0.25-10, self.contentView.width*0.25, self.contentView.height*0.25)];
    [self.contentView addSubview:closeButton];
    //closeButton.backgroundColor = [UIColor colorWithHexString:@"d7004c"];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    closeButton.layer.cornerRadius = 6;
    closeButton.layer.borderWidth = 1;
    closeButton.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    
    closeButton.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    closeButton.layer.shadowOpacity = 1;
    closeButton.layer.shadowRadius = 5;
    closeButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    [closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 重试按钮
    UIButton *retryButton =  [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.width-self.contentView.width*0.25-10, self.contentView.height-self.contentView.height*0.25-10, self.contentView.width*0.25, self.contentView.height*0.25)];;
    [self.contentView addSubview:retryButton];
    [retryButton setTitle:@"重试" forState:UIControlStateNormal];
    //    retryButton.backgroundColor = [UIColor colorWithHexString:@"01b361"];
    [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [retryButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    retryButton.layer.cornerRadius = 6;
    retryButton.layer.borderWidth = 1;
    retryButton.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    retryButton.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    retryButton.layer.shadowOpacity = 1;
    retryButton.layer.shadowRadius = 5;
    retryButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    [retryButton addTarget:self action:@selector(retryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //------- 调整弹窗高度和中心 -------//
    // self.contentView.height = retryButton.maxY + 10;
    //    self.contentView.center = self.center;
    
}

#pragma mark - 弹出此弹窗
/** 弹出此弹窗 */
- (void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

#pragma mark - 移除此弹窗
/** 移除此弹窗 */
- (void)dismiss{
    [self removeFromSuperview];
}

#pragma mark - 取消按钮点击
/** 取消按钮点击 */
- (void)closeButtonClicked{
    if ([self.delegate respondsToSelector:@selector(loadFailedAlertView:clickedButtonAtIndex:)]) {
        [self.delegate loadFailedAlertView:self clickedButtonAtIndex:AlertButtonLeft];
    }
    [self dismiss];
}

#pragma mark - 重试按钮点击
/** 重试按钮点击 */
- (void)retryButtonClicked{
    if ([self.delegate respondsToSelector:@selector(loadFailedAlertView:clickedButtonAtIndex:)]) {
        [self.delegate loadFailedAlertView:self clickedButtonAtIndex:AlertButtonRight];
    }
    [self dismiss];
}
@end
