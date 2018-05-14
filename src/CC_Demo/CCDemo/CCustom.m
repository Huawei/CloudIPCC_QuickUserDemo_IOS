//
//  CCustom.m
//  CCDemo
//
//  Created by mwx325691 on 16/5/27.
//  Copyright © 2016年 mwx325691. All rights reserved.
//

#import "CCustom.h"

@implementation CCustom

+ (UIButton *)butnWithFrame:(CGRect)frame title:(NSString *)title fontSize:(CGFloat)fontSize{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    UIColor *color = [UIColor colorWithRed:82.0/255.0 green:107.0/255.0 blue:149.0/255.0 alpha:1];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:color];
    
    return btn;
}

@end
