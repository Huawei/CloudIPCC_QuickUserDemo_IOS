//
//  CCommonUtil.m
//  CCSDK
//
//  Created by on 16/4/5.
//  Copyright © 2016年. All rights reserved.
//

#import "CCCommonUtil.h"
#import "CCDefineHead.h"
#import "CCAccountInfo.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>

#include <sys/types.h>
#include <sys/socket.h>


#define CHECKCSTR(str) (((str) == NULL) ? "" : (str))

@interface CCCommonUtil()

@end

@implementation CCCommonUtil

+ (NSString *)queryIpWithDomain:(NSString *)domain
{
    struct hostent *hs;
    struct sockaddr_in server;
    if ((hs = gethostbyname([domain UTF8String])) != NULL)
    {
        server.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
        return [NSString stringWithUTF8String:inet_ntoa(server.sin_addr)];
    }
    return nil;
}

+ (NSString *)localIPAddress
{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        NSMutableDictionary *addressDic = [[NSMutableDictionary alloc] init];
        while (temp_addr != NULL)
        {
            if( temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *addressName = [[NSString stringWithUTF8String:CHECKCSTR(temp_addr->ifa_name)] lowercaseString];
                NSString *addressIp = [NSString stringWithUTF8String:CHECKCSTR(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr))];
                if([addressName length]==0 || [addressIp length]==0)
                {
                    continue;
                }
                if ([addressName rangeOfString:@"tap"].length != 0 ||
                    [addressName rangeOfString:@"tun"].length != 0 ||//IPSec
                    [addressName rangeOfString:@"ppp"].length != 0)
                {//pptp
                    [addressDic setObject:addressIp forKey:@"vpn"];
                }
                else
                {
                    [addressDic setObject:addressIp forKey:addressName];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
        
        NSString *wifiConnectionAd = [addressDic objectForKey:@"en0"]; //from wifi
        NSString *wifiConnectionAd1 = [addressDic objectForKey:@"en1"]; //from wifi
        NSString *cellPhoneConnectionAd = [addressDic objectForKey:@"pdp_ip0"]; //from cell phone connection
        NSString *vpnConnectionAd = [addressDic objectForKey:@"vpn"];
        
        if ([vpnConnectionAd length] != 0)
        {
            address = vpnConnectionAd;
        }
        else if ([wifiConnectionAd length]!=0)
        {
            address = wifiConnectionAd;
        }
        else if ([cellPhoneConnectionAd length]!=0)  //from cellphone connection
        {
            address = cellPhoneConnectionAd;
        }
        else if ([wifiConnectionAd1 length] != 0)
        {
            address = wifiConnectionAd1;
        }
        else{
            address = @"";
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
    
}



+(BOOL)isValidIP:(NSString *)ip
{
    if ([ip length] == 0 || ip == nil)
    {
        return NO;
    }
    NSString *ipStr = [NSString stringWithString:ip];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(2\\d{0,2}|1\\d{0,2}|[1-9]\\d|[1-9]).\\d{0,3}.\\d{0,3}.\\d{0,3}$" options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipStr options:0 range:NSMakeRange(0, [ipStr length])];
        
        //如果没匹配到,就是格式不对了.
        if (!firstMatch)
        {
            return NO;
        }
    }
    
    NSArray *ipSectionarray = [ip componentsSeparatedByString:@"."];
    
    //先把ip拆开成字符串数组,如果不是4段,则ip地址不合法
    if ([ipSectionarray count] != 4)
    {
        return NO;
    }
    
    for (NSString *tempStr in ipSectionarray)
    {
        //不能有某个字段大于255
        if(tempStr.integerValue > 255)
        {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isValidPort:(NSString *)port
{
    if (port.length == 0 || port == nil)
    {
        return NO;
    }
    NSInteger count = [self regResult:@"[0-9]" param:port];
    if (count != port.length)
    {
        return NO;
    }
    NSInteger PORT = [port intValue];
    if ( PORT > 65535 || PORT <= 0)
    {
        return NO;
    }
    
    return YES;
}


+ (BOOL)vndidIsValid:(NSString *)str
{
    if (str.length == 0 || str == nil ||str.length>=4)
    {
        return NO;
    }
    NSInteger count = [self regResult:@"[0-9]" param:str];
    if (count != str.length)
    {
        return NO;
    }
    return YES;
}


+ (BOOL)isValidParam:(NSString *)str
{
    if (str.length > 20 || str.length < 1)
    {
        return NO;
    }

    NSInteger count = [self regResult:@"[A-Za-z0-9]" param:str];
    if (count != str.length)
    {
        return NO;
    }
    return YES;
}

+ (BOOL)callDataIsValid:(NSString *)callData
{
    if (callData == nil)
    {
        return NO;
    }

    NSInteger count = [self regResult:@"[A-Za-z0-9]" param:callData];
    if (count != callData.length)
    {
        return NO;
    }
    return YES;
}


+ (BOOL)callTypeIsValid:(NSString *)callType
{
    if (callType.length != 1)
    {
        return NO;
    }
    NSInteger count = [self regResult:@"[0-2]" param:callType];
    if (count != callType.length)
    {
        return NO;
    }
    
    return YES;
}
+ (BOOL)accessCodeIsValid:(NSString *)str
{
    if (str.length < 1 || str.length > 24)
    {
        return NO;
    }
    NSInteger count = [self regResult:@"[0-9]" param:str];
    if (count != str.length)
    {
        return NO;
    }
    return YES;
}

+ (NSInteger)regResult:(NSString *)regEx param:(NSString *)param
{
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regEx options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [reg numberOfMatchesInString:param options:NSMatchingReportProgress range:NSMakeRange(0, param.length)];
    return count;
}

+ (NSURLRequest *)createURLRequestWithURLString:(NSString *)urlString andRequestBody:(NSData *)body method:(NSString *)method isGuid:(BOOL)isGuid
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:ACCEPT_VALUE forHTTPHeaderField:ACCEPT_KEY];
    [request setValue:ACCEPT_ENCODING_VALUE forHTTPHeaderField:ACCEPT_ENCODING_KEY];
    [request setValue:CONTENT_TYPE_VALUE forHTTPHeaderField:CONTENT_TYPE_KEY];
    if (isGuid)
    {
        NSString *cookie = [CCAccountInfo shareInstance].cookie;
        
        NSString *guid = [CCAccountInfo shareInstance].guid;
        [request setValue:cookie forHTTPHeaderField:COOKIE_KEY];
        [request setValue:guid forHTTPHeaderField:GUID_KEY];
    }
    else
    {
        [request setValue:@"" forHTTPHeaderField:GUID_KEY];
    }
    [request setHTTPMethod:method];
    [request setHTTPBody:body];
    [request setTimeoutInterval:15];
    return request;
}

@end
