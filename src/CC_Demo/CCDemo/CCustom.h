//
//  CCustom.h
//  CCDemo
//
//  Created by mwx325691 on 16/5/27.
//  Copyright © 2016年 mwx325691. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LocalViewWidth (160)
#define LocalViewHeight (140)
#define ButtonHeight (40)

#define kSCREEN   [UIScreen mainScreen].bounds
#define kSWIDTH   [UIScreen mainScreen].bounds.size.width
#define kSHEIGHT  [UIScreen mainScreen].bounds.size.height

@interface CCustom : NSObject

+(UIButton *)butnWithFrame:(CGRect)frame title:(NSString *)title fontSize:(CGFloat)fontSize;

@end
