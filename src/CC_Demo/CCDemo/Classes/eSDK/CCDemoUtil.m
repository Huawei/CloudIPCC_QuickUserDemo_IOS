//
//  AGDemoUtil
//  AGDemo
//
//  Created by mwx325691 on 2016/10/14.
//  Copyright © 2016年 huawei. All rights reserved.
//


#import "CCDemoUtil.h"


@implementation CCDemoUtil

+ (BOOL)isIPValid:(NSString*)ip
{
    
    if ([ip length] == 0)
    {
        return NO;
    }
    NSString *ipStr = [NSString stringWithString:ip];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^((?:(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d))))$" options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipStr options:0 range:NSMakeRange(0, [ipStr length])];
        
        //如果没匹配到,就是格式不对了.
        if (!firstMatch)
        {
            return NO;
        }
        return YES;
    }
    return NO;
}


+ (BOOL)isPortValid:(NSString *)portStr
{
    if (portStr.length == 0 || portStr == nil)
    {
        return NO;
    }

    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [reg numberOfMatchesInString:portStr options:NSMatchingReportProgress range:NSMakeRange(0, portStr.length)];
  
    if (count != portStr.length)
    {
        return NO;
    }
    NSInteger PORT = [portStr intValue];
    if ( PORT > 65535 || PORT <= 0)
    {
        return NO;
    }
    return YES;
}

+ (BOOL)isAcodeValid:(NSString *)aCodeStr
{
    if (aCodeStr == nil || aCodeStr.length == 0 || aCodeStr.length > 32)
    {
        return NO;
    }
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [reg numberOfMatchesInString:aCodeStr options:NSMatchingReportProgress range:NSMakeRange(0, aCodeStr.length)];
    
    if (count != aCodeStr.length)
    {
        return NO;
    }

    return YES;
}

+ (BOOL)isNumber:(NSString*)inputStr
{
    if ([inputStr length] == 0)
    {
        return NO;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{1,}$" options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:inputStr options:0 range:NSMakeRange(0, [inputStr length])];
        //如果没匹配到,就是格式不对了.
        if (!firstMatch)
        {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (void)showAlertWithTitle:(NSString*)title content:(NSString*)content
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:content delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", "") otherButtonTitles:nil];
    [alertView show];
}
+ (void)showAlertSureWithTitle:(NSString*)title content:(NSString*)content
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alertView show];
}




+ (void)showAlertWithTitle:(NSString*)title content:(NSString*)content delegate:(id)del
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:content delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", "") otherButtonTitles:nil];
    alertView.delegate = del;
    [alertView show];
}



@end
