//
//  JKWKWebViewController.m
//  Pods
//
//  Created by Jack on 17/4/1.
//
//

#import "JKWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "CarAppConstant.h"
#import "JKEventHandler.h"
#import "JKEventHandler+Car.h"
#import "ShareManager.h"
#import "LoadFailedAlertView.h"
#import "LoadingProgressView.h"
#import "SSZipArchive.h"
#import "CAR_AFHTTPRequestOperation.h"




@interface JKWKWebViewController ()<WKNavigationDelegate, WKUIDelegate, LoadFailedAlertViewDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,copy) NSString *strFileName;  //标题
@property (nonatomic,copy) NSString *fileTmpPath;  //tap目录
@property (nonatomic, strong) UIButton      *backBtn;//返回按钮

@end

@implementation JKWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isGoBack = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [ShareManager shareInstance].wkWebVC = self;
    
    [self configureWKWebview];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:self action:@selector(goback)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"前进" style:UIBarButtonItemStyleDone target:self action:@selector(gofarward)];
    
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

- (void)configureWKWebview{
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    [config.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
    
    // web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[JKEventHandler shareInstance].handlerJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    
    [config.userContentController addUserScript:usrScript];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:[JKEventHandler shareInstance] name:EventHandler];
    
    //通过默认的构造器来创建对象
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                  configuration:config];

    //webview禁止滚动
    _webView.scrollView.bounces = false;
    
    //iOS 11对安全区域做了一些修改
    _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    
    //判断webview是/否加载本地
    //依据：1、选择在线模式 2、本地有下载的资源包
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strCarName = [userDefaults objectForKey:@"chooseCarModelName"];
    NSInteger nHaveLocal =[[userDefaults objectForKey: @"haveLocalPackaged"] integerValue];
    NSInteger nWebViewLoadMode = [[userDefaults objectForKey:@"webviewLoadMode"] integerValue];
    
    if([userDefaults objectForKey:@"webviewLoadMode"]){
        if(nWebViewLoadMode){
            //upload 是新增首页链接参数  拼接进去 为js显示提示更新（红点）啥的
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?upLoad=%@",_url,[userDefaults objectForKey:@"upLoad"]]]]];
        }else{
            NSString *strLocalCarName = [userDefaults objectForKey:@"localCarModelName"];
            NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/index.html",strLocalCarName]];
            [_webView loadFileURL:temDirURL allowingReadAccessToURL:temDirURL];
        }
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?upLoad=%@",[ShareManager shareInstance].wkWebVC.url,[userDefaults objectForKey:@"upLoad"]]]]];
    }
    [self.view addSubview:_webView];
    
    [JKEventHandler getInject:_webView];
    
    // 导航代理
    _webView.navigationDelegate = self;
    // 与webview UI交互代理
    _webView.UIDelegate = self;
    
    // 添加KVO监听
    [_webView addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [_webView addObserver:self
               forKeyPath:@"title"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [_webView addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    
}
/**
 返回按钮
 @return 关闭按钮
 */
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10*KScale, 10*KScale, 44/2*KScale, 35/2*KScale)];
        [_backBtn setImage:[UIImage imageNamed:@"button_web_back"] forState: UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (void)goback {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)gofarward {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

/*
 加载web页面失败弹框（无网络）
 */
- (void)showLoadFailedAlert{
    LoadFailedAlertView *alertView = [[LoadFailedAlertView alloc]initWithTitle:@"" message:@"" delegate:self leftButtonTitle:@"确定" rightButtonTitle:@"取消"];
    [alertView show];
}


/*
 下载本地资源
 */
- (void)downLoadZip{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strCarName = [userDefaults objectForKey:@"chooseCarModelName"];
    
    // NSHomeDirectory()：应用程序目录， @"tmp/temp"：在tmp文件夹下创建temp 文件夹
    //_fileTmpPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",strCarName]];
    _fileTmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    //判断文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:_fileTmpPath isDirectory:&isDir];
    //if ( !(isDir == YES && existed == YES) ) {
    // 在 tmp 目录下创建一个 temp 目录
    [fileManager createDirectoryAtPath:_fileTmpPath withIntermediateDirectories:YES attributes:nil error:nil];
    //下载解压
    [self startDownload];
    // }
    
}

/*
 进入设置页面
 */
-(void) goSettingWebView{
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
//        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        NSLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    if (!self.webView.loading) {
        // 手动调用JS代码
        // 每次页面完成都弹出来，大家可以在测试时再打开
//            NSString *js = @"memoryNav()";
//            [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//              NSLog(@"response: %@ error: %@", response, error);
//            }];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
        }];
    }
}

#pragma mark - WKNavigationDelegate
// 请求开始前，会先调用此代理方法
// 与UIWebView的
// - (BOOL)webView:(UIWebView *)webView
// shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(UIWebViewNavigationType)navigationType;
// 类型，在请求先判断能不能跳转（请求）
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:
(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);

//    NSLog(@"00===%s", __FUNCTION__);
}




// 在响应完成时，会回调此方法
// 如果设置为不允许响应，web内容就不会传过来
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
//    NSLog(@"11===%s", __FUNCTION__);
}


// 开始导航跳转时会回调
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
//    NSLog(@"22===%s", __FUNCTION__);
}

// 接收到重定向时会回调
- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
//    NSLog(@"33===%s", __FUNCTION__);
}


// 导航失败时会回调
- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"44===%s", __FUNCTION__);
   // [self showLoadFailedAlert];
    
}


// 页面内容到达main frame时回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
//    NSLog(@"55===%s", __FUNCTION__);
}


// 导航完成时，会回调（也就是页面载入完成了）
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    NSLog(@"66===%s", __FUNCTION__);
    
    NSArray *history = [webView.backForwardList backList];//历史记录的列表
    NSURL  *current =[webView.backForwardList currentItem].URL;//当前的URL

    if(_isGoBack){
        _isGoBack = NO;
        NSString *js = @"memoryNav()";
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//            NSLog(@"SDK response: %@ error: %@", response, error);
        }];
    }
    
    [self clean];
}

-(void) clean{
    
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >8) {
        NSArray * type=@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
        
        NSSet *websiteDataTypes = [NSSet setWithArray:type];
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
            // Done
            
        }];
        
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
//        NSLog(@"%@", cookiesFolderPath);
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        
    }
}


// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailNavigation:
(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"77===%s", __FUNCTION__);
    //[self showLoadFailedAlert];
}


// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:
(NSURLAuthenticationChallenge *)challenge completionHandler:
(void (^)(NSURLSessionAuthChallengeDisposition disposition,
          NSURLCredential *__nullable credential))completionHandler {
//    NSLog(@"88===%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}


// 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
//    NSLog(@"99===%s", __FUNCTION__);
   // [self showLoadFailedAlert];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
//    NSLog(@"100===%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:
                      UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                          completionHandler();
                      }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
//    NSLog(@"%@", message);
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
//    NSLog(@"101===%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                @"confirm" message:@"JS调用confirm"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                                                  completionHandler(YES);
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler(NO);
                                              }]];
    [self presentViewController:alert animated:YES completion:NULL];
//    NSLog(@"%@", message);
}


// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * __nullable result))completionHandler {
//    NSLog(@"102===%s", __FUNCTION__);
//    NSLog(@"%@", prompt);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                prompt message:defaultText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler([[alert.textFields lastObject] text]);
                                              }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc{
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:EventHandler];
    [_webView evaluateJavaScript:@"JKEventHandler.removeAllCallBacks();" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        
        
    }];//删除所有的回调事件
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Delegate - 加载失败的弹窗
// 输入框弹窗的button点击时回调
- (void)declareAbnormalAlertView:(LoadFailedAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == AlertButtonLeft) {
        // 取消按钮
        // [CQHUD showToastWithMessage:@"点击了左边的button"];
    }else{
        //重试按钮
        //[CQHUD showToastWithMessage:@"点击了右边的button"];
        [_webView reload];
    }
}

/*
 解压
 */
- (void)releaseZipFilesWithUnzipFileAtPath:(NSString *)zipPath Destination:(NSString *)unzipPath{
    NSError *error;
    if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath overwrite:YES password:nil error:&error delegate:self]) {
//        NSLog(@"success");
//        NSLog(@"unzipPath = %@",unzipPath);
        /*
         解压完成需要刷新 webview显示 本地html
         */
        
        //判断webview是/否加载本地
        //依据：1、选择在线模式 2、本地有下载的资源包
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *strCarName = [userDefaults objectForKey:@"chooseCarModelName"];
        NSInteger nHaveLocal =[[userDefaults objectForKey: @"haveLocalPackaged"] integerValue];
        NSInteger nWebViewLoadMode = [[userDefaults objectForKey:@"webviewLoadMode"] integerValue];
        if([userDefaults objectForKey:@"webviewLoadMode"]){
            if(nWebViewLoadMode){
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?upLoad=%@",_url,[userDefaults objectForKey:@"upLoad"]]]]];
            }else{
                NSString *strLocalCarName = [userDefaults objectForKey:@"localCarModelName"];
                NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/index.html",strLocalCarName]];
                [_webView loadFileURL:temDirURL allowingReadAccessToURL:temDirURL];
            }
        }else{
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?upLoad=%@",[ShareManager shareInstance].wkWebVC.url,[userDefaults objectForKey:@"upLoad"]]]]];
        }
        
    }else {
//        NSLog(@"%@",error);
    }
}


//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}
//开始下载
- (void)startDownload {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strCarName = [userDefaults objectForKey:@"chooseCarModelName"];
    
    NSString *path = [NSString stringWithFormat:@"%@%@%@",BaseURL,strCarName,@".zip"];
    NSString *escapedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSLog(@"escapedPath: %@", escapedPath);
    
    //设置文件下载路径
    NSString *downloadUrl = escapedPath;
    //@"www.haoweisys.com/OfflineInstaller/OfflineInstaller.zip";
    
    //设置文件保存路径
    NSString *caches=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath=[caches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",strCarName,@".zip"]];
    NSString *downloadPath=filePath;
//    NSLog(@"filePath: %@", filePath);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //检查文件是否已经下载了一部分
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        //获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:downloadPath];
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    //下载请求
    CAR_AFHTTPRequestOperation *operation = [[CAR_AFHTTPRequestOperation alloc] initWithRequest:request];
    //下载路径
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
    
    LoadingProgressView *alertView = [[LoadingProgressView alloc] initProgressView];
    [alertView show];

    //下载进度回调
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //下载进度
        float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
    
//        NSLog(@"%f",progress);
        [alertView setProgressValue:progress];


    }];
    //成功和失败回调
    [operation setCompletionBlockWithSuccess:^(CAR_AFHTTPRequestOperation *operation, id responseObject) {
        
        // 下载完成保存状态、现在车型名称
        [userDefaults setObject:[NSNumber numberWithInteger: STATE_HAVE_LOAD] forKey:@"haveLocalPackaged"];
        [userDefaults setObject:strCarName forKey:@"localCarModelName"];
        
        //保存本地资源版本号
        [userDefaults setObject:[userDefaults objectForKey:@"newVersion"] forKey:@"localVersion"];
        
        //设置模型
        [userDefaults setInteger:0 forKey:@"webviewLoadMode"];

        [userDefaults synchronize];
        
        //下载完成移除弹框
        [alertView dismiss];
        
        [self releaseZipFilesWithUnzipFileAtPath:filePath Destination:_fileTmpPath];
    } failure:^(CAR_AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [operation start];
}

#pragma mark - SSZipArchiveDelegate
- (void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo {
//    NSLog(@"将要解压。");
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPat uniqueId:(NSString *)uniqueId {
//    NSLog(@"解压完成！");
    
}


/**
 退出H5页面
 */
- (void)exitH5View {
    __weak __typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [strongSelf.bottomViewController exitH5View];
    }];
}

@end
