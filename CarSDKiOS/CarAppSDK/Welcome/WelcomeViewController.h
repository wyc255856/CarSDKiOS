//
//  DisclaimerViewController.h
//  CarApp
//
//  Created by 张三 on 2018/6/26.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

/**
 初始化方法，业务方创建后，以模态的形式加载这个 ViewController，创建方式如下：
 1.先倒入头文件：#import <CarAppSDK/WelcomeViewController.h>
 2.创建控制器，将下面的 xxxx 替换成车类型：
 WelcomeViewController *vc = [[WelcomeViewController alloc] initWithCarName:@"xxxx"];
 [self presentViewController:vc animated:YES completion:nil];

 @param carName 车类型
 @return VC
 */
- (id)initWithCarName:(NSString*)carName;

/**
 退出 SDK 方法，业务方无需调用这个方法，SDK 已经做了处理
 */
- (void)exitH5View;
@end
