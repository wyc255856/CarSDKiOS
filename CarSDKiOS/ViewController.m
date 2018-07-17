//
//  ViewController.m
//  CarSDKiOS
//
//  Created by Yu Chen on 2018/7/11.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "ViewController.h"
#import "WelcomeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 44)];
    [button setTitle:@"去看车" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1.0;
    [self.view addSubview:button];
    
}

- (void)buttonClicked {
    WelcomeViewController *vc = [[WelcomeViewController alloc] initWithCarName:nil];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
