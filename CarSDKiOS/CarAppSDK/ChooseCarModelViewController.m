//
//  ChooseCarModelViewController.m
//  CarApp
//
//  Created by Yu Chen on 2018/4/21.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "ChooseCarModelViewController.h"
#import "CarAppConstant.h"
#import "UIView+CARAdd.h"
#import "UIColor+Util.h"
#import "UIView+frameAdjust.h"
#import  "JKWKWebViewHandler.h"
#import "JKWKWebViewController.h"

@interface ChooseCarModelViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView   *bgImageView;   //背景图片
@property (nonatomic, strong) UILabel       *topTitleLabel;      //请选择当前车型
@property (nonatomic, strong) UIView        *searchView;     //显示选项框
@property (nonatomic, strong) UILabel       *searchViewLabel;//显示所选车型
@property (nonatomic, strong) UIButton      *searchViewBtn;//显示所选车型
@property (nonatomic, strong) UIButton      *closeBtn;//关闭按钮
@property (nonatomic, strong) UIButton      *submitBtn;//进入H5页面按钮
@property (nonatomic, strong) UIView        *chooseCarModelView;    //选项
@property (nonatomic, assign) BOOL          showChooseCarModelView;//是否显示选项
@property (nonatomic, assign) NSInteger     chooseCarModelIndex;//用来记录选择了什么车型


@end

@implementation ChooseCarModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showChooseCarModelView = false;
    self.chooseCarModelIndex = 100001;
    [self configView];
    
}

- (void)configView {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.searchView];
    [self.view addSubview:self.topTitleLabel];
    //[self.view addSubview:self.closeBtn];
    //[self.view addSubview:self.submitBtn];
    [self.view addSubview:self.chooseCarModelView];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
        NSString *resNameBg = @"bg_style_1";
        UIImage *imageBg =  resourceBundle?[UIImage imageNamed:resNameBg inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameBg];

        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _bgImageView.image = imageBg;
    }
    return _bgImageView;
}

- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _searchView.top - 30*KScale, kScreenWidth, 20*KScale)];
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topTitleLabel.font = [UIFont systemFontOfSize:12*KScale];
        _topTitleLabel.text = @"请选择当前车型";
    }
    return _topTitleLabel;
}

- (UIView *)searchView {
    if (!_searchView) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
  
        //        _searchView = [[UIView alloc] initWithFrame:CGRectMake(100*KScale, _topTitleLabel.bottom + 10*KScale, 150*KScale, 20*KScale)];
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*0.5, 20*KScale)];
        _searchView.centerX = self.view.centerX;
        
        //适配iponex  强行适配有问题啊！*******************
        if(KIsiPhoneX){
            _searchView.centerY = self.view.centerY+1.5*KScale;
        }else{
            _searchView.centerY = self.view.centerY+ 2*KScale;
        }
        
        //_searchView.backgroundColor = [UIColor colorWithHexString:@"#09497b"];
        _searchView.layer.borderWidth = 1;
        _searchView.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        _searchView.layer.cornerRadius = 18;
        
        _searchView.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        _searchView.layer.shadowOpacity = 1;
        _searchView.layer.shadowRadius = 5;
        _searchView.layer.shadowOffset = CGSizeMake(0, 0);
        
        
        //添加左侧的文字展示
        _searchViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(5*KScale, 0, 100*KScale, 20*KScale)];
        _searchViewLabel.text = @"手动舒适";
        _searchViewLabel.textColor = [UIColor whiteColor];
        _searchViewLabel.textAlignment = NSTextAlignmentLeft;
        _searchViewLabel.font = [UIFont systemFontOfSize:10*KScale];
        _searchViewLabel.userInteractionEnabled = false;
        [_searchView addSubview:_searchViewLabel];
        
        //添加右侧的按钮
        _searchViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(_searchView.width-29*KScale, KScale, 28*KScale, 18*KScale)];//按钮周围边框留空1像素
        _searchViewBtn.userInteractionEnabled = false;
        // 图片名称
        NSString *resNameSearch = @"button_select_car_down";
        UIImage *imageSearch =  resourceBundle?[UIImage imageNamed:resNameSearch inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameSearch];
        [_searchViewBtn setImage:imageSearch forState: UIControlStateNormal];
        // _searchViewBtn.backgroundColor =  [UIColor colorWithHexString:@"#5380a3"];
        //        _searchViewBtn.layer.borderWidth = 1;
        //        _searchViewBtn.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        //        _searchViewBtn.layer.cornerRadius = 18;
        //        _searchViewBtn.layer.cornerRadius = 16;
        //        _searchViewBtn.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        //        _searchViewBtn.layer.shadowOpacity = 1;
        //        _searchViewBtn.layer.shadowRadius = 5;
        //        _searchViewBtn.layer.masksToBounds = YES;
        //        _searchViewBtn.layer.shadowOffset = CGSizeMake(-3, 3);
                
        [_searchView addSubview:_searchViewBtn];
        
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(searchViewClicked)];
        [_searchView addGestureRecognizer:tapGesture];
        
    }
    return _searchView;
}


/**
 关闭按钮
 
 @return 关闭按钮
 */
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(_searchView.left-30, _searchView.bottom+10*KScale, 198/2*KScale, 82/2*KScale)];
        [_closeBtn setImage:[UIImage imageNamed:@"button_select_car_close"] forState: UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

/**
 确认按钮
 
 @return 确认按钮，去H5页面
 */
- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(_closeBtn.right-20, _searchView.bottom+10*KScale, 198/2*KScale, 82/2*KScale)];
        [_submitBtn setImage:[UIImage imageNamed:@"button_select_car_right"] forState: UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

- (void)buttonClicked:(id)object {
    UIButton *btn = (UIButton *)object;
    NSInteger tag = btn.tag;
    _chooseCarModelIndex = btn.tag;
    switch (tag) {
        case 100001:
            _searchViewLabel.text = @"手动舒适";
            break;
        case 100002:
            _searchViewLabel.text = @"手动豪华";
            break;
        case 100003:
            _searchViewLabel.text = @"手动尊贵";
            break;
        case 100004:
            _searchViewLabel.text = @"自动舒适";
            break;
        case 100005:
            _searchViewLabel.text = @"自动豪华";
            break;
        case 100006:
            _searchViewLabel.text = @"自动尊贵";
            break;
        case 100007:
            _searchViewLabel.text = @"自动旗舰";
            break;
        default:
            break;
    }
    
    //选择车型后关闭弹框
    [self searchViewClicked];
    
    //选择完车型 1s后确认选择
    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(timer, dispatch_get_main_queue(), ^(void){
        [self submit];
    });
    
}


- (UIView *)chooseCarModelView {
    if (!_chooseCarModelView) {
        //每行文字的高度
        float btnHeight = 14*KScale;
        float btnLeft = 5*KScale;
        float lineHeight = 5*KScale;
        UIColor *lineViewColor = [UIColor colorWithHexString:@"#1bb2fa"];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *bundleURL = [bundle URLForResource:@"CarResource" withExtension:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
        
        _chooseCarModelView = [[UIView alloc] initWithFrame:CGRectMake(_searchView.left, _searchView.bottom+10*KScale, _searchView.width, kScreenHeight-_searchView.bottom-25*KScale)];
        //_chooseCarModelView.backgroundColor = [UIColor colorWithHexString:@"#09497b"];
        _chooseCarModelView.layer.cornerRadius = 6;
        _chooseCarModelView.layer.borderWidth = 1;
        _chooseCarModelView.layer.borderColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        _chooseCarModelView.layer.cornerRadius = 8;
        _chooseCarModelView.hidden = YES;//默认不显示选项
        
        //边框添加阴影代码
        _chooseCarModelView.layer.shadowColor = [[UIColor colorWithHexString:@"#1bb2fa"] CGColor];
        _chooseCarModelView.layer.shadowOpacity = 1;
        _chooseCarModelView.layer.shadowRadius = 5;
        _chooseCarModelView.layer.shadowOffset = CGSizeMake(0, 0);
        
        
        [self.view addSubview:_chooseCarModelView];
        
        // 1.创建UIScrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, 0, _chooseCarModelView.width, _chooseCarModelView.height);
        scrollView.delegate = self;
        [_chooseCarModelView addSubview:scrollView];
        
        // 隐藏水平滚动条
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        //ScrollView的子视图 包涵滚动内容
        UIView *scrollSubView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _searchView.width, (btnHeight+lineHeight)*7)];
        [scrollView addSubview:scrollSubView];
        
        scrollView.alwaysBounceVertical = YES;
        // 设置UIScrollView的滚动范围（内容大小）
        scrollView.contentSize = scrollSubView.size;
        
        float lineWidth = _chooseCarModelView.width-5*KScale*2;
        float lineLeft = 5*KScale;
        //手动舒适
        UIButton *sdssBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, 0.5*lineHeight, _chooseCarModelView.width, btnHeight)];
        sdssBtn.tag = 100001;
        sdssBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [sdssBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [sdssBtn setTitle:@"手动舒适" forState: UIControlStateNormal];
        [sdssBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:sdssBtn];
        
        UIImageView * sdssLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, sdssBtn.bottom, lineWidth, lineHeight)];
        NSString *resNameLine = @"line";
        UIImage *imageLine1=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];
        [sdssLineImgView setImage:imageLine1];
        [scrollSubView addSubview:sdssLineImgView];
        
        //手动豪华
        UIButton *sdhhBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, sdssLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        sdhhBtn.tag = 100002;
        sdhhBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [sdhhBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [sdhhBtn setTitle:@"手动豪华" forState: UIControlStateNormal];
        [sdhhBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:sdhhBtn];
        
        UIImageView * sdhhLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, sdhhBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine2=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];
        [sdhhLineImgView setImage:imageLine2];
        [scrollSubView addSubview:sdhhLineImgView];
        
        
        //手动尊贵
        UIButton *sdzgBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, sdhhLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        sdzgBtn.tag = 100003;
        sdzgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [sdzgBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [sdzgBtn setTitle:@"手动尊贵" forState: UIControlStateNormal];
        [sdzgBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:sdzgBtn];
        
        UIImageView * sdzgLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, sdzgBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine3=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];

        [sdzgLineImgView setImage:imageLine3];
        [scrollSubView addSubview:sdzgLineImgView];
        
        
        //自动舒适
        UIButton *zdssBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, sdzgLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        zdssBtn.tag = 100004;
        zdssBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [zdssBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [zdssBtn setTitle:@"自动舒适" forState: UIControlStateNormal];
        [zdssBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:zdssBtn];
        
        UIImageView * zdssLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, zdssBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine4=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];

        [zdssLineImgView setImage:imageLine4];
        [scrollSubView addSubview:zdssLineImgView];
        
        
        //自动豪华
        UIButton *zdhhBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, zdssLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        zdhhBtn.tag = 100005;
        zdhhBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [zdhhBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [zdhhBtn setTitle:@"自动豪华" forState: UIControlStateNormal];
        [zdhhBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:zdhhBtn];
        
        UIImageView * zdhhLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, zdhhBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine5=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];
        [zdhhLineImgView setImage:imageLine5];
        [scrollSubView addSubview:zdhhLineImgView];
        
        //自动尊贵
        UIButton *zdzgBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, zdhhLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        zdzgBtn.tag = 100006;
        zdzgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [zdzgBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [zdzgBtn setTitle:@"自动尊贵" forState: UIControlStateNormal];
        [zdzgBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:zdzgBtn];
        
        UIImageView * zdzgLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, zdzgBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine6=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];
        [zdzgLineImgView setImage:imageLine6];
        [scrollSubView addSubview:zdzgLineImgView];
        
        
        //自动旗舰
        UIButton *zdqjBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnLeft, zdzgLineImgView.bottom, _chooseCarModelView.width, btnHeight)];
        zdqjBtn.tag = 100007;
        zdqjBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [zdqjBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        [zdqjBtn setTitle:@"自动旗舰" forState: UIControlStateNormal];
        [zdqjBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollSubView addSubview:zdqjBtn];
        
        UIImageView * zdqjLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineLeft, zdqjBtn.bottom, lineWidth, lineHeight)];
        UIImage *imageLine7=  resourceBundle?[UIImage imageNamed:resNameLine inBundle:resourceBundle compatibleWithTraitCollection:nil]:[UIImage imageNamed:resNameLine];
        [zdqjLineImgView setImage:imageLine7];
        [scrollSubView addSubview:zdqjLineImgView];
        
        
    }
    return _chooseCarModelView;
}


/**
 关闭按钮
 */
- (void)close {
    UIApplication *app = (UIApplication *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.keyWindow;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

/**
 跳转去H5页面
 */
- (void)submit {
    //汽车类型
    NSString *strCarTypeName;
    
    switch (_chooseCarModelIndex) {
        case 100001:
            NSLog(@"手动舒适");
            strCarTypeName = typeManualComfortable;
            break;
        case 100002:
            NSLog(@"手动豪华");
            strCarTypeName = typeManualLuxury;
            break;
        case 100003:
            NSLog(@"手动尊贵");
            strCarTypeName = typeManualHonorable;
            break;
        case 100004:
            NSLog(@"自动舒适");
            strCarTypeName = typeAutomaticComfortable;
            break;
        case 100005:
            NSLog(@"自动豪华");
            strCarTypeName = typeAutomaticLuxury;
            break;
        case 100006:
            NSLog(@"自动尊贵");
            strCarTypeName = typeAutomaticHonorable;
            break;
        case 100007:
            NSLog(@"自动旗舰");
            strCarTypeName = typeAutomaticUltimate;
            break;
        default:
            break;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInteger: _chooseCarModelIndex] forKey:@"chooseCarModelIndex"];
    [userDefaults setObject:strCarTypeName forKey:@"chooseCarModelName"];
    [userDefaults setInteger:MODE_ONLINE forKey:@"webviewLoadMode"];
    
    [userDefaults synchronize];
    
    //进入web首页
    [self goJKWKWebViewWithURL:[NSString stringWithFormat:@"%@%@",BaseURL,strCarTypeName]];
    
}

/*
 进入web首页
 */
-(void) goJKWKWebViewWithURL: (NSString*) url{
    JKWKWebViewController *jkVC = [JKWKWebViewController new];
    //    NSString *url = [NSString stringWithFormat:@"file://%@",[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"]];
    jkVC.url = url;
    [self presentViewController:jkVC  animated:NO completion:nil];
    
}

/**
 点击选择框，显示选项/隐藏选项
 */
- (void)searchViewClicked {
    if (!self.showChooseCarModelView) {
        _chooseCarModelView.hidden = false;
        _showChooseCarModelView = true;
    } else {
        _chooseCarModelView.hidden = true;
        _showChooseCarModelView = false;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
