//
//  ChooseCarModelViewController.h
//  CarApp
//
//  Created by Yu Chen on 2018/4/21.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCarModelViewController : UIViewController
@property (nonatomic, weak) id bottomViewController;

/**
 退出 SDK 方法，业务方无需调用这个方法，SDK 已经做了处理
 */
- (void)exitH5View;
@end
