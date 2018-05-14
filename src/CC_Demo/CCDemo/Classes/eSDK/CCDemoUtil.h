//
//  AGDemoUtil
//  AGDemo
//
//  Created by mwx325691 on 2016/10/14.
//  Copyright © 2016年 huawei. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCDemoUtil : NSObject

/**
 *  判断IP地址是否有效
 *
 *  @param ipStr 输入的IP地址
 *
 *  @return 是否有效
 */
+ (BOOL)isIPValid:(NSString*)ipStr;

/**
 *  判断端口号是否合法
 *
 *  @param port 端口号
 *
 *  @return 是否合法
 */
+ (BOOL)isPortValid:(NSString *)portStr;
/**
 *  判断access code是否合法
 *
 *  @param aCodeStr: access code
 *
 *  @return 是否合法
 */
+ (BOOL)isAcodeValid:(NSString *)aCodeStr;

/**
 *  判断字符串是否为数字
 *
 *  @param inputStr 输入字符串
 *
 *  @return 是否为数字
 */
+ (BOOL)isNumber:(NSString*)inputStr;

/**
 *  显示一个提示框,提示框只有一个确认按钮
 *
 *  @param title   提示框的标题
 *  @param content 要提示的内容
 */
+ (void)showAlertWithTitle:(NSString*)title content:(NSString*)content;

+ (void)showAlertSureWithTitle:(NSString*)title content:(NSString*)content;

+ (void)showAlertWithTitle:(NSString*)title content:(NSString*)content delegate:(id)del;




@end
