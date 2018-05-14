//
//  MBProgressHUD+MJ.h
//
//  Created by huawei on 17-11-21.
//  Copyright (c) 2017年 huawei. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;


//只显示文字
+ (MBProgressHUD *)showMessage:(NSString *)message;

//显示文字和进度层
+ (MBProgressHUD *)showMessageWithHUD:(NSString *)text toView:(UIView *)view;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
