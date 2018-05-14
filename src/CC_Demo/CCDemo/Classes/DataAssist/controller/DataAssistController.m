//
//  DataAssistController.m
//  CCDemo
//
//  Created by Tom on 2017/12/26.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import "DataAssistController.h"
#import "DataAssistBottomView.h"
#import "CCAccountInfo.h"
#import "CCICSService.h"
#import "CCConfManager.h"
#import "CCNotificationsDefine.h"

@interface DataAssistController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *assistBtn;
@property (nonatomic,strong)DataAssistBottomView *bottomView;

@property (nonatomic,strong) UIScrollView *screeScrollView;

@property (nonatomic, strong) UIImageView *screenshareView;

@property (nonatomic,strong) UIScrollView *fileScrollView;

@property (nonatomic, strong) UIImageView *fileImageView;

@property (nonatomic, strong) UILabel *meettingLab;

@property (nonatomic, strong) UIButton *leaveBtn;

@property (nonatomic,strong ) UILabel *screeLab;

@property (nonatomic,strong) UILabel *fileLab;


@end

@implementation DataAssistController
- (IBAction)assitClick:(id)sender {
//    [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:VIDEO_CALL callData:[NSString stringWithFormat:@"(VIDEO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.codeField.text];

}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.view addSubview:self.bottomView];
    
    [self initView];
    
    [self addNotification];
    
    self.screeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIdTH, 200)];
    self.screeScrollView.contentSize = CGSizeMake(SCREEN_WIdTH, 0);
    self.screeScrollView.delegate = self;
    self.screeScrollView.minimumZoomScale = 1;
    self.screeScrollView.maximumZoomScale = 3;
    self.screeScrollView.tag = 1001;
    self.screeScrollView.bounces = NO;
    self.screeScrollView.scrollEnabled = YES;
    self.screeScrollView.showsHorizontalScrollIndicator = NO;
    self.screeScrollView.showsVerticalScrollIndicator = NO;
    
    self.screenshareView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIdTH, 200)];
    self.screenshareView.multipleTouchEnabled = YES;
    self.screenshareView.userInteractionEnabled = YES;
//    self.screenshareView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.screeScrollView];
    [self.screeScrollView addSubview:self.screenshareView];
    
//     UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
//    [self.screenshareView addGestureRecognizer:pinchGestureRecognizer];
//
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    
//    [self.screenshareView addGestureRecognizer:panGestureRecognizer];
    
    self.fileScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.fileLab.y+64, SCREEN_WIdTH, 200)];
    self.fileScrollView.contentSize = CGSizeMake(SCREEN_WIdTH, 0);
    self.fileScrollView.delegate = self;
    self.fileScrollView.tag = 1002;
    self.fileScrollView.minimumZoomScale = 1;
    self.fileScrollView.maximumZoomScale = 3;
    self.fileScrollView.bounces = NO;
    self.fileScrollView.scrollEnabled = YES;
    self.fileScrollView.showsHorizontalScrollIndicator = NO;
    self.fileScrollView.showsVerticalScrollIndicator = NO;
    
    self.fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIdTH, 200)];
    self.fileImageView.userInteractionEnabled = YES;
    self.fileImageView.multipleTouchEnabled = YES;
    
    [self.view addSubview:self.fileScrollView];
    [self.fileScrollView addSubview:self.fileImageView];
    
//    [self.view addSubview:self.meettingLab];
    [self.view addSubview:self.leaveBtn];
    
    [self.view addSubview:self.screeLab];
    [self.view addSubview:self.fileLab];
    
    [[CCUtil shareInstance] setDesktopShareContainer:self.screenshareView];
    [[CCUtil shareInstance] setFileShareContainer:self.fileImageView];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeskShare:)
                                                 name:CALL_MSG_ON_SCREEN_DATA_RECEIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deskShareStop:)
                                                 name:CALL_MSG_ON_SCREEN_SHARE_STOP object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createMeetingSuccess:)
                                                 name:@"createMeetingSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseMeeting:)
                                                 name:CALL_MSG_ON_MEETING_RELEASE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminalCall:)
                                                 name:@"terminalCall" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLeave:)
                                                 name:CALL_MSG_ON_USER_LEAVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseConf:)
                                                 name:@"releaseConf" object:nil];
    
    
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView.tag == 1001) {
        return self.screenshareView;
    }else{
        return self.fileImageView;
    }
    
}
-(void)releaseConf:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.screenshareView setImage:nil];
        [self.fileImageView setImage:nil];
        [CCDemoUtil showAlertSureWithTitle:@"提示" content:@"会议结束"];
    });
}
-(void)userLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.screenshareView setImage:nil];
        [self.fileImageView setImage:nil];
         [CCDemoUtil showAlertSureWithTitle:@"提示" content:@"会议结束"];
    });
}
- (void)terminalCall:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fileImageView setImage:nil];
        [self.screenshareView setImage:nil];
         [CCDemoUtil showAlertSureWithTitle:@"提示" content:@"会议结束"];
    });
}
- (void)releaseMeeting:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.meettingLab.text = [NSString stringWithFormat:@"当前无会议"];
    });
}
- (void)createMeetingSuccess:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
         self.meettingLab.text = [NSString stringWithFormat:@"会议ID:%@",[CCAccountInfo shareInstance].stopConfId ];
    });
   
}
- (void)receiveDeskShare:(NSNotification *)notification
{
    NSLog(@"notification");
}

- (void)deskShareStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.screenshareView setImage:nil];
//        self.screenshareView.frame = CGRectMake(0, 0, SCREEN_WIdTH, 200);®
//        self.screenshareView.backgroundColor = [UIColor blackColor];
    });
   
}

- (void)initView
{
    
}

- (void)leaveMeeting
{
    [[CCConfManager shareInstance] terminalConf];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DataAssistBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[DataAssistBottomView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIdTH,64)];
    }
    return _bottomView;
}

- (UILabel *)meettingLab
{
    if (!_meettingLab) {
        _meettingLab = [[UILabel alloc] initWithFrame:CGRectMake(self.fileImageView.x, self.fileImageView.y+200, SCREEN_WIdTH/2, 40)];
        _meettingLab.textColor = [UIColor blackColor];
        _meettingLab.textAlignment = NSTextAlignmentCenter;
        _meettingLab.text =@"当前无会议";
    }
    return _meettingLab;
}

- (UIButton *)leaveBtn
{
    if (!_leaveBtn) {
        _leaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIdTH/2, self.fileScrollView.y+200, SCREEN_WIdTH/2, 40)];
        [_leaveBtn setTitle:@"离开会议" forState:UIControlStateNormal];
        _leaveBtn.layer.borderWidth = 1.0;
        _leaveBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _leaveBtn.layer.masksToBounds = YES;
         _leaveBtn.layer.cornerRadius = 5.0;
        [_leaveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leaveBtn addTarget:self action:@selector(leaveMeeting) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leaveBtn;
}

- (UILabel *)screeLab
{
    if (!_screeLab) {
        _screeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIdTH, 64)];
        _screeLab.text = @"屏幕共享视图:";
    }
    return _screeLab;
}

- (UILabel *)fileLab
{
    if (!_fileLab) {
        _fileLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 264, SCREEN_WIdTH, 64)];
        _fileLab.text = @"文档共享视图:";
    }
    return _fileLab;
}
@end
