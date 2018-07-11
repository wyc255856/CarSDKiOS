//
//  JKEventHandler+Car.h
//  CarApp
//
//  Created by 张三 on 2018/3/30.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "JKWKWebViewHandler.h"
@interface JKEventHandler (Car)
- (void)goSetPage:(id)params;
- (void)selectModel:(id)params;
- (void)cleanCache:(id)params;
- (void)modeCheck:(id)params;
- (void)downloadZip:(id)params;
- (void)getModel:(void(^)(id response))callBack;
- (void)getMode:(void(^)(id response))callBack;
- (void)goBack:(id)params;
- (void)goHome:(id)params;
- (void)exitApp:(id)params;
- (void)upLoad:(id)params;






@end
