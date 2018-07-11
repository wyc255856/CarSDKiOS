//
//  CarBundleTool.m
//  CarAppSDK
//
//  Created by Yu Chen on 2018/7/7.
//  Copyright © 2018年 freedomTeam. All rights reserved.
//

#import "CarBundleTool.h"

@implementation CarBundleTool
+(NSBundle*)getUIBaseBundle{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"CarResource" withExtension:@"bundle"]];
    return bundle;
}

+(UIImage*)getImageInBundleWithName:(NSString *)imageName {
    if(!imageName)return nil;
    NSBundle *bundle = [self getUIBaseBundle];
    NSString *imagePath = nil;
    UIImage *imageIM = nil;
    //如果包括2x、3x
    if ([imageName containsString:@"@2x"]||[imageName containsString:@"@3x"]) {
        imagePath = [bundle pathForResource:imageName ofType:@"png"];
        imageIM = [UIImage imageWithContentsOfFile:imagePath];
        
    }else {
        imagePath = [bundle pathForResource:imageName ofType:@"png"];
        imageIM = [UIImage imageWithContentsOfFile:imagePath];
        if (!imageIM) {
            CGFloat scale =[[UIScreen mainScreen] scale];
            imageName = [NSString stringWithFormat:@"%@@%dx",imageName,(int)scale];
            imagePath = [bundle pathForResource:imageName ofType:@"png"];
            imageIM = [UIImage imageWithContentsOfFile:imagePath];
            
        }
    }
    
    return imageIM;
}
@end
