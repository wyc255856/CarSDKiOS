//
//  LoadFailedAlertView.h
//  CarApp
//
//  Created by 张三 on 2018/4/19.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 弹窗上的按钮
 
 - AlertButtonLeft: 左边的按钮
 - AlertButtonRight: 右边的按钮
 */
typedef NS_ENUM(NSUInteger, AbnormalButton) {
    AlertButtonLeft = 0,
    AlertButtonRight
};


#pragma mark - 协议

@class LoadFailedAlertView;

@protocol LoadFailedAlertViewDelegate <NSObject>

- (void)loadFailedAlertView:(LoadFailedAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@interface LoadFailedAlertView : UIView

/** 这个弹窗对应的内容 */
@property (nonatomic,copy) NSString *content;

@property (nonatomic,weak) id<LoadFailedAlertViewDelegate> delegate;
/**
 弹窗的构造方法
 @param title 弹窗标题
 @param message 弹窗message
 @param delegate 确定代理方
 @param leftButtonTitle 左边按钮的title
 @param rightButtonTitle 右边按钮的title
 @return 一个申报异常的弹窗
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate leftButtonTitle:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle;

/** show出这个弹窗 */
- (void)show;

@end
