//
//  CCAccountInfo.m
//  CCUtil
//
//  Created by  on 16/4/1.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCAccountInfo.h"

static CCAccountInfo *userAccountInfo = nil;

@implementation CCAccountInfo

+ (CCAccountInfo *)shareInstance
{
    @synchronized(self)
    {
        if (userAccountInfo == nil)
        {
            userAccountInfo = [[CCAccountInfo alloc] init];
        }
    }
    return userAccountInfo;
}

@end
