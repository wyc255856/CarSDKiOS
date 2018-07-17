//
//  DisclaimerViewController.m
//  CarApp
//
//  Created by 张三 on 2018/6/26.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "WelcomeViewController.h"
#import "JKWKWebViewController.h"
#import "ChooseCarModelViewController.h"
#import "CarAppConstant.h"
#import "CAR_AFNetworking.h"
#import "CarBundleTool.h"

@interface WelcomeViewController (){
    int _timeCount;
    BOOL Finish;
    BOOL Splash;
    BOOL Visitor;
}
@property (nonatomic, strong) UIImageView   *bgSplashImageView;   //闪屏背景图片
@property (nonatomic, strong) UIImageView   *bgDisclaimerImageView;   //免责声明背景图片
@property (nonatomic, strong) UILabel       *timingLabel;   //显示计时
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Finish = NO;
    if(Splash){
        [self configSDKView];
    }else{
        [self configView];
    }
 
}

-(id) initWithCarName: (NSString*) carName{
    if(self = [super init]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        Splash = YES;
        if(![self isBlankString:carName]){
            NSString *sModolName = kFuncGetCarTypeByCarName(carName);
            if(!sModolName){
                sModolName = typeManualComfortable;
            }
            [userDefaults setObject:sModolName  forKey:@"chooseCarModelName"];
            Visitor = NO;
            [userDefaults setObject:@"NO" forKey:@"Visitor"];

        }else{
            [userDefaults setObject:@"YES" forKey:@"Visitor"];
            Visitor = YES;
        }
        [userDefaults synchronize];
    }
    return self;
}
- (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
#pragma clang diagnostic ignored "-Wmismatched-return-types"
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#pragma clang diagnostic pop
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (void)configView {
    [self.view addSubview:self.bgDisclaimerImageView];
    [self.view addSubview:self.timingLabel];
}

- (void)configSDKView {
    [self.view addSubview:self.bgSplashImageView];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.view addSubview:self.bgDisclaimerImageView];
        [self.view addSubview:self.timingLabel];
    });
}

- (UIImageView *)bgSplashImageView {
    if (!_bgSplashImageView) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];

        _bgSplashImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenHeight, kScreenWidth)];
        if(KIsiPhoneX){
            // 图片名称
            NSString *resName = @"bg_splash_2436*1125";
            UIImage *image =  resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];
            _bgSplashImageView.image = image;
        }else{
            NSString *resName = @"splash";
            UIImage *image =  resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];
            _bgSplashImageView.image = image;

        }
    }
    return _bgSplashImageView;
}

- (UIImageView *)bgDisclaimerImageView {
    if (!_bgDisclaimerImageView) {
        _bgDisclaimerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
        
        if(KIsiPhoneX){
            // 图片名称
            NSString *resName = @"bg_disclaimer_2436*1125";
            UIImage *image =  resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];
            _bgDisclaimerImageView.image = image;
        }else{
            // 图片名称
            NSString *resName = @"disclaimer@2x";
            UIImage *image =  resourceBundle?[UIImage imageNamed:resName inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resName];
            _bgDisclaimerImageView.image =image;
        }
    }
    return _bgDisclaimerImageView;
}


- (UILabel *)timingLabel {
    if (!_timingLabel) {
        [self performSelectorInBackground:@selector(thread) withObject:nil];
        _timingLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100*KScale, 10*KScale, 80*KScale, 20*KScale)];
        _timingLabel.textColor = [UIColor whiteColor];
        _timingLabel.textAlignment = NSTextAlignmentCenter;
        _timingLabel.font = [UIFont systemFontOfSize:10*KScale];
        _timingLabel.text = @"剩余5秒 跳过>";
    }
    return _timingLabel;
}

// 在异步线程中无法操作UI，如果想要操作UI必须回调主线程
- (void)thread
{
    for(int i=6;i>=0;i--)
    {
        _timeCount = i;
        if(!Finish){
            // 回调主线程
            [self performSelectorOnMainThread:@selector(mainThread) withObject:nil waitUntilDone:YES];
            sleep(1);
        }
    }
}

// 此函数主线程执行
- (void)mainThread
{
    if (_timeCount>3) {
        _timingLabel.text=[NSString stringWithFormat:@"%@%d%@",@"剩余",_timeCount,@"秒"];
    }else{
        if(_timeCount>0){
            _timingLabel.text=[NSString stringWithFormat:@"%@%d%@",@"剩余",_timeCount,@"秒 跳过>"];
            
            UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goNext)];
            [_timingLabel addGestureRecognizer:labelTapGestureRecognizer];
            _timingLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击

        }else{
            [self goNext];
        }
    }
}

// 3. 在此方法中设置点击label后要触发的操作
- (void)goNext {
    Finish = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 是否选择车型
    //NSInteger chooseCarModelIndex = [[userDefaults objectForKey: @"chooseCarModelIndex"] integerValue];
    NSString *strCarName = [userDefaults objectForKey:@"chooseCarModelName"];
    // 下载本地资源包 版本号字段 （默认本地资源版本号为1.0.0）
    if(![userDefaults objectForKey:@"localVersion"]){
        [userDefaults setObject:@"1.0.0" forKey:@"localVersion"];
        // 是否需要下载字段（1：需要 0:不需要 为了拼接后面的设置页面的链接 实现下载最新资源包）
        [userDefaults setObject:@"1" forKey:@"upLoad"];
    }
    
    //获取服务器最新资源版本号
    [self getAppNewVersion];
    if(Visitor == NO){
        JKWKWebViewController *jkVC = [JKWKWebViewController new];
        jkVC.url = [NSString stringWithFormat:@"%@%@",BaseURL,strCarName];
        jkVC.bottomViewController = self;
        [self presentViewController:jkVC  animated:NO completion:nil];
    }else{
        ChooseCarModelViewController *vc = [[ChooseCarModelViewController alloc] init];
        [self presentViewController:vc  animated:NO completion:nil];
    }
}

-(void)getAppNewVersion
{
    //初始化manager
    CAR_AFHTTPSessionManager *manager = [CAR_AFHTTPSessionManager manager];
    
    //序列化
    manager.responseSerializer = [CAR_AFHTTPResponseSerializer serializer];
    
    //Get请求
    NSString *url = @"http://www.haoweisys.com/c217_admin/index.php/home/index/get_new_version/car_series/C217/car_type/1";
    
    [manager GET:url parameters:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功，解析数据
        NSString* sVersion;
        sVersion = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //与服务器版本号一致 sameVersion 为0
        if([sVersion compare:[userDefaults objectForKey:@"localVersion"]]){
            [userDefaults setObject:@"0" forKey:@"upLoad"];
        }
        //本地保存服务端最新资源版本 如下载最新资源改变本地资源localVerson版本号
        [userDefaults setObject:sVersion forKey:@"newVersion"];
//        NSLog(@"%@", sVersion);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
//        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)exitH5View {
    [self dismissViewControllerAnimated:NO completion:^{
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
