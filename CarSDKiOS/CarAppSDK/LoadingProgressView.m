//
//  LoadingProgressView.m
//  CarApp
//
//  Created by 张三 on 2018/4/20.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "LoadingProgressView.h"
#import "UIColor+Util.h"
#import "UIView+frameAdjust.h"
#import "CarBundleTool.h"


@interface LoadingProgressView ()
/** 弹窗主内容view */
@property (nonatomic,strong) UIView   *contentView;
/** 进度条 **/
@property (nonatomic,strong) UIProgressView   *progressView;
/** 进度 label */
@property (nonatomic,strong) UILabel  *progressValueLabel;

/** 显示进度 **/
@property (nonatomic,copy)   NSString *progressValue;


@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation LoadingProgressView{
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

/*
 下载弹窗的构造方法
 */
- (instancetype)initProgressView{
    if (self = [super init]) {
        //self.delegate = delegate;
        
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
    //[bgImgView setImage:[UIImage imageNamed:@"bg_style_1"]];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
    
    NSString *resName = @"bg_style_1";
    [bgImgView setImage:resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName]];
    [self addSubview:bgImgView];
    
    //------- 弹窗主内容 -------//
    self.contentView = [[UIView alloc]init];
    self.contentView.frame = CGRectMake((SCREEN_WIDTH - 400) / 2, (SCREEN_HEIGHT - 20) / 2, SCREEN_WIDTH*0.7, 80);
    self.contentView.center = self.center;
    [self addSubview:self.contentView];
    //    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#09497b"];
    //    self.contentView.layer.cornerRadius = 6;
    //    self.contentView.layer.borderWidth = 1;
    //    self.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    
    //------- 下载图标 -------//
    //UIImage * loadIconImg =  [UIImage imageNamed:@"icon_load"];
    NSString *resLoadName = @"icon_load";
    UIImage *loadIconImg =  resourceBundle?[UIImage imageNamed:resLoadName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];

    UIImageView *loadIconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (self.contentView.frame.size.height - loadIconImg.size.height)/2, loadIconImg.size.width, loadIconImg.size.height)];
    loadIconView.image = loadIconImg;
    [self.contentView addSubview:loadIconView];
    
    //------- 进度值 -------//
    self.progressValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*0.7-70, (self.contentView.frame.size.height-22)/2, 60, 22)];
    
    [self.contentView addSubview:self.progressValueLabel];
    self.progressValueLabel.font = [UIFont boldSystemFontOfSize:20];
    self.progressValueLabel.textAlignment = NSTextAlignmentCenter;
    self.progressValueLabel.textColor = [UIColor colorWithHexString:@"#dee9f5"];
    self.progressValueLabel.text = @"%0";
    
    //------- 进度条 -------//
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(loadIconView.frame.size.width+40, (self.contentView.frame.size.height)/2, self.contentView.frame.size.width-loadIconView.frame.size.width-self.progressValueLabel.frame.size.width -60 , 15)];
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 5;
    //更改进度条高度
    self.progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
    
    self.progressView.trackTintColor= [UIColor clearColor];
    
    self.progressView.progressTintColor= [UIColor whiteColor];
    
    [self.contentView addSubview:self.progressView];
    
    
    //这个容器 因为进度条的  进度覆盖了轨道 需求轨道是包含在外的 强行添加一个轨道放在进度条上面
    UIView *containerProView = [[UIView alloc] initWithFrame:CGRectMake(loadIconView.frame.size.width+40+1, (self.contentView.frame.size.height-self.progressView.frame.size.height)/2, self.progressView.frame.size.width-1 , self.progressView.frame.size.height+1)];
    
    containerProView.layer.cornerRadius = 5;
    containerProView.layer.borderWidth = 1;
    containerProView.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    
    containerProView.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
    containerProView.layer.shadowOpacity = 1;
    containerProView.layer.shadowRadius = 5;
    containerProView.layer.shadowOffset = CGSizeMake(0, 0);
    [self.contentView addSubview:containerProView];
    
    
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

/*
 设置progre值方法
 @param value 对应数字 0.0～1.0
 */
- (void) setProgressValue: (float) fValue{
    
    NSString *strTempValue=[NSString stringWithFormat:@"%0.2f", fValue];
    self.progressView.progress= [strTempValue floatValue];
    
    NSString *tempString = @"%";
    self.progressValueLabel.text = [tempString stringByAppendingString:[NSString stringWithFormat:@"%d",(int)(fValue*100)]];
    
}

@end
