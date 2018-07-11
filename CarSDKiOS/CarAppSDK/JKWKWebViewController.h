//
//  JKWKWebViewController.h
//  Pods
//
//  Created by Jack on 17/4/1.
//
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"

@interface JKWKWebViewController : UIViewController
@property (nonatomic, weak) WelcomeViewController *bottomViewController;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign, getter=isValue) BOOL isGoBack;

- (void)showLoadFailedAlert;
- (void)downLoadZip;
- (void)goSettingWebView;
- (void)exitH5View;
@end
