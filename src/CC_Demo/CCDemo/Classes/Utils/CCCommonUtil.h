//
//  CCommonUtil.h
//  CCSDK
//
//  Created by  on 16/4/5.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCommonUtil : NSObject

+ (NSString *)queryIpWithDomain:(NSString *)domain;

/**
*  获取本地ip
*
*  @return 本地ip
*/
+ (NSString*)localIPAddress;

/**
 *  判断ip是否合法
 *
 *  @param ip 待检测ip字符串
 *
 *  @return ip是否合法
 */
+(BOOL)isValidIP:(NSString*)ip;


/**
 *  判断端口号是否合法
 *
 *  @param port 端口号
 *
 *  @return 是否合法
 */
+ (BOOL)isValidPort:(NSString *)port;

/**
 *  登录的vndid是否合法
 *
 *  @param str str
 *
 *  @return BOOL
 */
+ (BOOL)vndidIsValid:(NSString *)str;


/**
 *  判断是否只含数字或者字母
 *
 *  @param str str
 *
 *  @return bool
 */
+ (BOOL)isValidParam:(NSString *)str;

/**
 *  判断接入码是否合法
 *
 *  @param str str
 *
 *  @return BOOL
 */
+ (BOOL)accessCodeIsValid:(NSString *)str;

/**
 *  判断呼叫随录是否合法
 *
 *  @param callData callData
 *
 *  @return BOOL
 */
+ (BOOL)callDataIsValid:(NSString *)callData;

/**
 *  判断呼叫类型是否合法
 *
 *  @param callType 呼叫类型
 *
 *  @return bool
 */
+ (BOOL)callTypeIsValid:(NSString *)callType;

/**
 *  request
 *
 *  @param urlString url
 *  @param body      请求体
 *  @param path      Path
 *
 *  @return NSURLRequest对象
 */
+(NSURLRequest *)createURLRequestWithURLString:(NSString *)urlString andRequestBody:(NSData *)body method:(NSString *)method isGuid:(BOOL)isGuid;

@end
