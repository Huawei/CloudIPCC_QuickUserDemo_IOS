//
//  MediaViewController.m
//  CCDemo
//
//  Created by mwx325691 on 16/4/18.
//  Copyright © 2016年 mwx325691. All rights reserved.
//
/*
#import "TPViewController.h"
#import "EAGLView.h"

@interface TPViewController ()<UIAlertViewDelegate>
{
    BOOL _micisMute;
    BOOL _speakisMute;
    BOOL _isBackCamera;
    BOOL _isVideoInfo;
    BOOL _callSuccess;
    BOOL _isMute;
    dispatch_source_t _callTimer;
    dispatch_source_t _videoTimer;
    dispatch_source_t _queueTimer;
    NSInteger _rotate;
    NSInteger _count;
}

@property (nonatomic, strong) UITextView *videoInfoView;
@property (nonatomic, strong) EAGLView *remoteView;
@property (nonatomic, strong) EAGLView *localView;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *videoCallBtn;
@property (nonatomic, strong) UIButton *micMuteBtn;
@property (nonatomic, strong) UIButton *muteBtn;
@property (nonatomic, strong) UIButton *speakMuteBtn;
@property (nonatomic, strong) UIButton *rotateBtn;
@property (nonatomic, strong) UIButton *videoInfoBtn;
@property (nonatomic, strong) UIButton *cameraSwitchBtn;

@end

@implementation TPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor grayColor];
    _speakisMute = YES;
    _rotate = 0;
    _count = 0;
    [self composition];
    //[self TPCall];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callSuccess:)
                                                 name:CALL_MSG_ON_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callEnd:)
                                                 name:CALL_MSG_ON_DISCONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callFail:)
                                                 name:CALL_MSG_ON_FAIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callIsQueuing:)
                                                 name:CALL_MSG_ON_QUEUING object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveQueueInfo:)
                                                 name:CALL_MSG_ON_QUEUE_INFO object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueTimeOut:)
                                                 name:CALL_MSG_ON_QUEUE_TIMEOUT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueIsCancel:)
                                                 name:CALL_MSG_ON_CANCEL_QUEUE object:nil];
}


- (void)callSuccess:(NSNotification *)notify
{
    _callSuccess = YES;
    [self stopCallTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteView deleteBlackSublayer];
        [self.localView deleteBlackSublayer];
        [self.cancelBtn removeFromSuperview];
        [self.remindLabel removeFromSuperview];
        UIView *view = [self.view viewWithTag:1001];
        if( view!= nil){
            [view removeFromSuperview];
        }
    });
}

- (void)callEnd:(NSNotification *)notify
{
    [self stopVideoTimer];
    [self stopCallTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteView addBlackSublayer];
        [self.localView addBlackSublayer];
        UIView *view = [self.view viewWithTag:1001];
        if( view!= nil){
            [view removeFromSuperview];
        }
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"CallEnd", "") delegate:self];
    });
}

- (void)callFail:(NSNotification *)notify
{
    NSString *failResult = (NSString *)notify.object;
   
    [self stopCallTimer];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Fail", ""),failResult] delegate:self];
    });
}

- (void)callIsQueuing:(NSNotification *)notify
{
    [self stopCallTimer];
    [self startQueueTimer];
   
}

-(void)startQueueTimer{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _queueTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_queueTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_queueTimer, ^{
        [self getQueue];
    });
    
    dispatch_source_set_cancel_handler(_queueTimer, ^{
        _queueTimer =nil;
    });
    dispatch_resume(_queueTimer);
}

- (void)stopQueueTimer
{
    if (_queueTimer)
    {
        dispatch_source_cancel(_queueTimer);
    }
}

- (void)receiveQueueInfo:(NSNotification *)notify
{
    NSDictionary *queueInfo = (NSDictionary *)notify.userInfo;
    if (queueInfo ==nil)
    {
        [self stopQueueTimer];
        if (![self.remindLabel.text isEqualToString:NSLocalizedString(@"Canceling", "")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.remindLabel.text = NSLocalizedString(@"QueueEnd", "");
            });
        }
    }else{
        if (![self.remindLabel.text isEqualToString:NSLocalizedString(@"Canceling", "")]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *queueStr = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@",NSLocalizedString(@"Position", ""),[queueInfo objectForKey:POSITION_KEY],NSLocalizedString(@"OnlineAgentNum", ""),[queueInfo objectForKey:ONLINEAGENTNUM_KEY],NSLocalizedString(@"LongsWaitTime", ""),[queueInfo objectForKey:LONGESTWAITTIME_KEY]];
                self.remindLabel.text = queueStr;
            });
        }
    }
}

- (void)queueTimeOut:(NSNotification *)notify
{
    [self stopQueueTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"QueueTimeOut", "") delegate:self];
    });
}

- (void)getQueue
{
    [[CCUtil shareInstance] getCallQueueInfo];
}

- (void)queueIsCancel:(NSNotification *)notify{
    NSLog(@"queue canceled");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [self.view viewWithTag:1001];
        if( view!= nil){
            [view removeFromSuperview];
        }
         [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Canceled", "") delegate:self];
    });
}

- (void)cancelClick
{
    if (_callSuccess)
    {
        [[CCUtil shareInstance] releaseCall];
        [self stopVideoTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.remoteView addBlackSublayer];
            [self.localView addBlackSublayer];
            [self.navigationController popViewControllerAnimated:NO];
        });
        return;
    }
  
    [self stopQueueTimer];
    [[CCUtil shareInstance] cancelQueue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remindLabel.text = NSLocalizedString(@"Canceling", "");
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        [view setBackgroundColor:[UIColor blackColor]];
        [view setAlpha:0.5];
        [view setTag:1001];
        [self.view addSubview:view];
    });
    
}

- (void)micMuteClick
{
    if (!_callSuccess){
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(micMute) object:nil];
    [self performSelector:@selector(micMute) withObject:nil afterDelay:1.0];
}


- (void)micMute
{
    if (_micisMute)
    {
        [[CCUtil shareInstance] setMicMute:NO];
        [self.micMuteBtn setTitle:NSLocalizedString(@"MicMute", "") forState:UIControlStateNormal];
        _micisMute = NO;
        return;
    }
    [[CCUtil shareInstance] setMicMute:YES];
    [self.micMuteBtn setTitle:NSLocalizedString(@"OpenMic", "") forState:UIControlStateNormal];
    _micisMute = YES;
}

- (void)rotateClick
{
    if (!_callSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    _rotate += 90;
    if (_rotate > 270) {
        _rotate = 0;
    }
    BOOL success = [[CCUtil shareInstance] setVideoRotate:_rotate];
    NSLog(@"success = %d",success);
    if (!success){
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"rotate fail", "")];
    }
}

- (void)speakMuteClick
{
    if (!_callSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(speakMute) object:nil];
    [self performSelector:@selector(speakMute) withObject:nil afterDelay:1.0];
}

- (void)speakMute
{
    if (_isMute)
    {
        [[CCUtil shareInstance] setSpeakerMute:NO];
        [self.muteBtn setTitle:NSLocalizedString(@"Mute", "") forState:UIControlStateNormal];
        _isMute = NO;
        return;
    }
    [[CCUtil shareInstance] setSpeakerMute:YES];
    [self.muteBtn setTitle:NSLocalizedString(@"CancelMute", "") forState:UIControlStateNormal];
    _isMute = YES;
}


- (void)callClick
{
    if (!_callSuccess)
    {
       [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[CCUtil shareInstance] releaseCall];
    [self stopVideoTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteView addBlackSublayer];
        [self.localView addBlackSublayer];
        [self.navigationController popViewControllerAnimated:NO];
    });
}

- (void)checkVideoInfoClick
{
    if (!_callSuccess)
    {
       [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(getVideoInfo) object:nil];
    [self performSelector:@selector(getVideoInfo) withObject:nil afterDelay:1.0];
}


- (void)getVideoInfo
{
    if (_isVideoInfo)
    {
        [self stopVideoTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoInfoBtn setTitle:NSLocalizedString(@"VideoInfo", "") forState:UIControlStateNormal];
        });
        _isVideoInfo = NO;
        return;
    }
    
    if (!_callSuccess)
    {
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
            return;
    }
    [self startVideoTimer];
    
    _isVideoInfo = YES;
   
}

-(void)startVideoTimer{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _videoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_videoTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_videoTimer, ^{
        NSLog(@"startVideoTimer wakeup");
        [self getVideoStreamInfo];
    });
    
    dispatch_source_set_cancel_handler(_videoTimer, ^{
        NSLog(@"startVideoTimer cancel");
        _videoTimer =nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoInfoView.text = @"";
            [self.videoInfoBtn setTitle:NSLocalizedString(@"VideoInfo", "") forState:UIControlStateNormal];
        });
    });
    dispatch_resume(_videoTimer);
}

- (void)stopVideoTimer
{
    if (_videoTimer)
    {
        dispatch_source_cancel(_videoTimer);
    }
}

- (void)switchCameraClick
{
    if (!_callSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cameraSwitch) object:nil];
    [self performSelector:@selector(cameraSwitch) withObject:nil afterDelay:0.7];
}

- (void)cameraSwitch
{
    _rotate = 0;
    if (_isBackCamera)
    {
        [[CCUtil shareInstance] switchCamera:1];
        _isBackCamera = NO;
         [self.cameraSwitchBtn setTitle:NSLocalizedString(@"FrontCamera", "BackCam") forState:UIControlStateNormal];
        return;
    }
    [[CCUtil shareInstance] switchCamera:0];
    _isBackCamera = YES;
     [self.cameraSwitchBtn setTitle:NSLocalizedString(@"BackCamera", "FrontCam") forState:UIControlStateNormal];
}

- (void)changeAudioRouteClick
{
    if (!_callSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeRoute) object:nil];
    [self performSelector:@selector(changeRoute) withObject:nil afterDelay:0.7];
}

- (void)changeRoute
{
    if (!_speakisMute)
    {
        [[CCUtil shareInstance] changeAudioRoute:0];
        [self.speakMuteBtn setTitle:NSLocalizedString(@"Speaker", "") forState:UIControlStateNormal];
        _speakisMute = YES;
        return;
    }
    [[CCUtil shareInstance] changeAudioRoute:1];
    [self.speakMuteBtn setTitle:NSLocalizedString(@"Receiver", "") forState:UIControlStateNormal];
    _speakisMute = NO;
}

- (void)getVideoStreamInfo
{
    Stream_INFO info = [[CCUtil shareInstance] getChannelInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoInfoBtn setTitle:NSLocalizedString(@"CloseInfo", "") forState:UIControlStateNormal];
         self.videoInfoView.text = [NSString stringWithFormat:@"%@:%f\n%@:%fms\n%@:%f\n%@:%fms\n%@:%s\n%@:%s",NSLocalizedString(@"SendLossFraction", ""),info.sendLossFraction,NSLocalizedString(@"SendDelay", ""),info.sendDelay,NSLocalizedString(@"ReceiveLossFraction", ""),info.receiveLossFraction,NSLocalizedString(@"ReceiveDelay", ""),info.receiveDelay,NSLocalizedString(@"EncodeSize", ""),info.encodeSize,NSLocalizedString(@"DecodeSize", ""),info.decodeSize];
        
    });
}
/*
- (void)TPCall
{
     [[CCUtil shareInstance] setTransportSecurityUseTLS:[LoginInfo sharedInstance].isTLS useSRTP:[LoginInfo sharedInstance].isTLS];
    [[CCUtil shareInstance] setDataRate:768];
    [[CCUtil shareInstance] setVideoMode:0];
    [[CCUtil shareInstance] setVideoContainer:self.localView remoteView:self.remoteView];
    [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].TPACode callType:VIDEO_CALL callData:[LoginInfo sharedInstance].TPCallData verifyCode:[LoginInfo sharedInstance].VCode];
    self.remindLabel.text = NSLocalizedString(@"Calling", "");
    
    [self startCallTimer];
    
}
*/
/*
-(void)startCallTimer{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _callTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_callTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_callTimer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_callTimer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                                       content:NSLocalizedString(@"CallTimeOut", "") delegate:self];
            });
        }else{
          timeout--;
        }
    });
    
    dispatch_source_set_cancel_handler(_callTimer, ^{
        _callTimer =nil;
        
    });
    dispatch_resume(_callTimer);
}

- (void)stopCallTimer
{
    if (_callTimer)
    {
        dispatch_source_cancel(_callTimer);
    }
}


- (void)composition
{
    CGFloat kWidth = kSWIDTH/7;
    CGFloat y = kSHEIGHT - ButtonHeight;
    self.rotateBtn = [CCustom butnWithFrame:CGRectMake(kWidth * 2, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"Rotate", "") fontSize:14];
    [self.rotateBtn addTarget:self action:@selector(rotateClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoCallBtn = [CCustom butnWithFrame:CGRectMake(kWidth * 3, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"VideoHangUp", "") fontSize:14];
    [self.videoCallBtn addTarget:self action:@selector(callClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.micMuteBtn = [CCustom butnWithFrame:CGRectMake(kWidth, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"MicMute", "") fontSize:14];
    [self.micMuteBtn addTarget:self action:@selector(micMuteClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraSwitchBtn = [CCustom butnWithFrame:CGRectMake(0, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"FrontCamera", "BackCam") fontSize:14];
    [self.cameraSwitchBtn addTarget:self action:@selector(switchCameraClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.speakMuteBtn = [CCustom butnWithFrame:CGRectMake(kWidth * 4, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"Speaker", "")fontSize:14];
    [self.speakMuteBtn addTarget:self action:@selector(changeAudioRouteClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.muteBtn = [CCustom butnWithFrame:CGRectMake(kWidth * 5, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"Mute", "") fontSize:14];
    [self.muteBtn addTarget:self action:@selector(speakMuteClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoInfoBtn = [CCustom butnWithFrame:CGRectMake(kWidth * 6, y, kWidth-1, ButtonHeight) title:NSLocalizedString(@"VideoInfo", "") fontSize:14];
    [self.videoInfoBtn addTarget:self action:@selector(checkVideoInfoClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSWIDTH/2 - 100, 20, 150, 120)];
    self.remindLabel.textColor = [UIColor redColor];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.font = [UIFont systemFontOfSize:15];
    self.remindLabel.numberOfLines = 3;
    
    self.remoteView = [EAGLView getRemoteVideoViewWithFrame:CGRectMake(0, 0, kSWIDTH, kSHEIGHT - ButtonHeight)];
    self.remoteView.backgroundColor = [UIColor grayColor];
    self.remoteView.userInteractionEnabled = YES;
    
    [self.remoteView addSubview:self.remindLabel];
    
    self.localView =  [EAGLView getLocalVideoViewWithFrame:CGRectMake(0 , 0, LocalViewWidth, LocalViewHeight)];
    self.localView.backgroundColor = [UIColor grayColor];
    
    self.cancelBtn = [CCustom butnWithFrame:CGRectMake(kSWIDTH-90, 20, 90, 50) title:NSLocalizedString(@"Cancel", "") fontSize:15];
    [self.cancelBtn setTitleShadowColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoInfoView = [[UITextView alloc] initWithFrame:CGRectMake(kSWIDTH - LocalViewWidth, 0, LocalViewWidth, 100)];
    self.videoInfoView.editable = NO;
    self.videoInfoView.selectable=NO;
    self.videoInfoView.textColor = [UIColor redColor];
    self.videoInfoView.showsHorizontalScrollIndicator = NO;
    self.videoInfoView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.remindLabel];
    [self.view addSubview:self.rotateBtn];
    [self.view addSubview:self.videoCallBtn];
    [self.view addSubview:self.micMuteBtn];
    [self.view addSubview:self.cameraSwitchBtn];
    [self.view addSubview:self.speakMuteBtn];
    [self.view addSubview:self.videoInfoBtn];
    [self.view addSubview:self.muteBtn];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.remoteView];
    [self.view addSubview:self.localView];
    [self.view sendSubviewToBack:self.localView];
    [self.view sendSubviewToBack:self.remoteView];
    [self.remoteView addSubview:self.videoInfoView];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });

}

@end
*/
