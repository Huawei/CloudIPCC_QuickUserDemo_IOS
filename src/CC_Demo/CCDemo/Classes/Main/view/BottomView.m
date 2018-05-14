//
//  BottomView.m
//  CCDemo
//
//  Created by Tom on 2017/12/26.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import "BottomView.h"
@interface BottomView()

@property (nonatomic,strong)UIButton *setBtn;

@property (nonatomic,strong)UIButton *videoBtn;

@property (nonatomic,strong)UIButton *dataAssistBtn;

@property (nonatomic,strong)UIView *lineView;

@end
@implementation BottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.setBtn];
        [self addSubview:self.videoBtn];
        [self addSubview:self.dataAssistBtn];
        [self addSubview:self.lineView];
    }
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.masksToBounds = YES;
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lineView.y = self.height-10;
   
    
}
#pragma mark-lazy
-(UIButton *)setBtn
{
    if (!_setBtn) {
        _setBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width/3, 64)];
        [_setBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_setBtn setTitle:@"设置" forState:UIControlStateNormal];
        [_setBtn addTarget:self action:@selector(clickSet) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setBtn;
}

-(UIButton *)videoBtn
{
    if (!_videoBtn) {
        _videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width/3, 0, self.width/3, 64)];
        [_videoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_videoBtn setTitle:@"视频" forState:UIControlStateNormal];
        [_videoBtn addTarget:self action:@selector(clickVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}

-(UIButton *)dataAssistBtn
{
    if (!_dataAssistBtn) {
        _dataAssistBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width*2/3, 0, self.width/3, 64)];
        [_dataAssistBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_dataAssistBtn setTitle:@"数据协作" forState:UIControlStateNormal];
        [_dataAssistBtn addTarget:self action:@selector(clickDataAssist) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dataAssistBtn;
}

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width*2/9, 2)];
        _lineView.backgroundColor = [UIColor grayColor];
        _lineView.centerX = self.setBtn.centerX;
    }
    return _lineView;
}


#pragma mark-action
- (void)clickSet
{
    if (self.indexBlock) {
        self.indexBlock(0);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.lineView.centerX = self.setBtn.centerX;
    }];
    
}

- (void)clickVideo
{
    if (self.indexBlock) {
        self.indexBlock(1);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.lineView.centerX = self.videoBtn.centerX;
    }];
    
}

- (void)clickDataAssist
{
    if (self.indexBlock) {
        self.indexBlock(2);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.lineView.centerX = self.dataAssistBtn.centerX;
    }];
    
}


@end
