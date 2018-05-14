//
//  TimeUtil.m
//  CCDemo
//
//  Created by Tom on 2018/2/5.
//  Copyright © 2018年 mwx325691. All rights reserved.
//

#import "TimeUtil.h"
#import "CCICSService.h"

static TimeUtil *timeUtil = nil;
@interface TimeUtil ()



@property (nonatomic,assign)int leaveTime;

@end

@implementation TimeUtil

+ (TimeUtil *)shareInstance
{
    @synchronized(self)
    {
        if (timeUtil == nil)
        {
            timeUtil = [[TimeUtil alloc] init];
        }
    }
    return timeUtil;
}

- (void)startTimer
{
    if (self.timer) {
        
    }else{
        self.timer  = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkNetwork) userInfo:nil repeats:YES];
        self.leaveTime = 120;
    }
   
    
    
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    self.leaveTime = 0;
}

- (void)checkNetwork
{
    if (self.leaveTime>0) {
        self.leaveTime--;
        NSLog(@"%d",self.leaveTime);
    }else{
        [self.timer invalidate];
        self.timer = nil;
        self.leaveTime = 0;
        [CCICSService shareInstance].isLogout = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkerror" object:@"-5"];
    }
}


@end
