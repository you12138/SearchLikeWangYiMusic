//
//  MBProgressHUD+LNFCategory.h
//  weiwoju2016
//
//  Created by 刘宁飞 on 2016/10/31.
//  Copyright © 2016年 weiwoju. All rights reserved.
//

#import "MBProgressHUD/MBProgressHUD.h"

@interface MBProgressHUD (LNFCategory)

/** 网络请求加载 */
+ (void)showLoadingHUDToView:(UIView *)view;
+ (void)hideLoadingHUDToView:(UIView *)view;




@end
