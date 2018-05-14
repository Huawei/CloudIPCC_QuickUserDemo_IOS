//
//  DataAssistBottomView.h
//  CCDemo
//
//  Created by Tom on 2017/12/27.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataAssistBottomView : UIView
@property (nonatomic,copy)void (^indexBlock)(int i);
@end
