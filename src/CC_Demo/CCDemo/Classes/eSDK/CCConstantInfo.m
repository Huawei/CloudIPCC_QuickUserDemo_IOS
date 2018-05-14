//
//  CConstantInfo.m
//  CCIOSSDK
//
//  Created by  on 16/7/8.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCConstantInfo.h"

@implementation CCConstantInfo

+ (CCConstantInfo *)shareInstance
{
    static CCConstantInfo *cconstInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (cconstInfo == nil)
        {
            cconstInfo = [[CCConstantInfo alloc] init];
        }
    });
    return cconstInfo;
}

@end
