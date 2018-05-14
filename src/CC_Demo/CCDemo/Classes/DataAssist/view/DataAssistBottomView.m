//
//  DataAssistBottomView.m
//  CCDemo
//
//  Created by Tom on 2017/12/27.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import "DataAssistBottomView.h"
@interface DataAssistBottomView()
@property (nonatomic,strong)UIButton *firstBtn;

@property (nonatomic,strong)UIButton *centerBtn;

@property (nonatomic,strong)UIButton *lastBtn;

@end
@implementation DataAssistBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.firstBtn];
        [self addSubview:self.centerBtn];
        [self addSubview:self.lastBtn];
    }
    return self;
}

#pragma mark-lazy
-(UIButton *)firstBtn
{
    if (!_firstBtn) {
        _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width/3, 64)];
        [_firstBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_firstBtn setTitle:@"第一页" forState:UIControlStateNormal];
        [_firstBtn addTarget:self action:@selector(clickFirst) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstBtn;
}
-(UIButton *)centerBtn
{
    if (!_centerBtn) {
        _centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width/3, 0, self.width/3, 64)];
        [_centerBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_centerBtn setTitle:@"中间页" forState:UIControlStateNormal];
        [_centerBtn addTarget:self action:@selector(clickCenter) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerBtn;
}
-(UIButton *)lastBtn
{
    if (!_lastBtn) {
        _lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(2*self.width/3, 0, self.width/3, 64)];
        [_lastBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_lastBtn setTitle:@"最后一页" forState:UIControlStateNormal];
        [_lastBtn addTarget:self action:@selector(clickLast) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastBtn;
}
#pragma mark-action
- (void)clickFirst
{
    if (self.indexBlock) {
        self.indexBlock(0);
    }
}

- (void)clickCenter
{
    if (self.indexBlock) {
        self.indexBlock(1);
    }
}

- (void)clickLast
{
    if (self.indexBlock) {
        self.indexBlock(2);
    }
}
@end
