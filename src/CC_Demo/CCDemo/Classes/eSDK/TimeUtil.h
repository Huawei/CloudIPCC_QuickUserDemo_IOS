//
//  TimeUtil.h
//  CCDemo
//
//  Created by Tom on 2018/2/5.
//  Copyright © 2018年 mwx325691. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject

@property (nonatomic,strong)NSTimer *timer;

+ (TimeUtil *)shareInstance;

- (void)startTimer;

- (void)stopTimer;

@end
