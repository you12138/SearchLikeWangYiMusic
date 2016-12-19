//
//  MBProgressHUD+LNFCategory.m
//  weiwoju2016
//
//  Created by 刘宁飞 on 2016/10/31.
//  Copyright © 2016年 weiwoju. All rights reserved.
//

#import "MBProgressHUD+LNFCategory.h"
//#import "Public.h"

@implementation MBProgressHUD (LNFCategory)


/** 网络请求加载 */
+ (void)showLoadingHUDToView:(UIView *)view
{
    UIImageView *hudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingHud"]];
    hudImage.frame = CGRectMake(0, 0, 25, 25);
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    //rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    //rotationAnimation.repeatCount = repeat;
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[rotationAnimation];
    animationGroup.repeatCount = 99999;
    animationGroup.duration = 2;
    //[img.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [hudImage.layer addAnimation:animationGroup forKey:@"rotationAnimation"];
    
    MBProgressHUD *hudView = [[MBProgressHUD alloc] initWithView:view];
//    hudView.bezelView.backgroundColor = RGBA(47, 59, 100, 1.0);;
    hudView.mode = MBProgressHUDModeCustomView;
    hudView.customView = hudImage;
    [view addSubview:hudView];
    [hudView showAnimated:YES];
    
}
+ (void)hideLoadingHUDToView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}



@end
