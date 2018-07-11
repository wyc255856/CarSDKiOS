//
//  LoadingProgressView.h
//  CarApp
//
//  Created by 张三 on 2018/4/20.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingProgressView : UIView
/*
下载弹窗的构造方法
*/
- (instancetype)initProgressView;

/** show出这个弹窗 */
- (void)show;

/** 移除此弹窗 */
- (void)dismiss;

/*
 设置progre值方法
 @param value 对应数字 0.0～1.0
 */
- (void) setProgressValue: (float) fValue;

@end
