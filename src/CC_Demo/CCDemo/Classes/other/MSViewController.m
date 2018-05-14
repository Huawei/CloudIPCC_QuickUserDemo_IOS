//
//  MSViewController.m
//  CCDemo
//
//  Created by mwx325691 on 16/5/12.
//  Copyright © 2016年 mwx325691. All rights reserved.
//



#import "MSViewController.h"
#import "EAGLView.h"

@interface MSViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    BOOL _videoViewOpen;
    BOOL _shareViewOpen;
    BOOL _audioSuccess;
    BOOL _videoSuccess;
    BOOL _screenShare;
    BOOL _speakIsMute;
    BOOL _isBackCamera;
    BOOL _isHResolution;
    BOOL _isCalling;
    BOOL _isWebCall;
    NSInteger _rotate;
    
    NSString *_msgStr;
    CGFloat _KWIDTH;
    CGFloat _kwidth;
    CGRect _oldFrame;
    NSInteger _count;
    dispatch_source_t _callTimer;
    dispatch_source_t _queueTimer;
}

@property (nonatomic, strong) UIImageView *screenshareView;
@property (nonatomic, strong) EAGLView *remoteView;
@property (nonatomic, strong) EAGLView *localView;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, strong) UIButton *audionBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *sendMsgBtn;
@property (nonatomic, strong) UITextField *chatText;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UITextView *queueinfoText;
@property (nonatomic, strong) UIButton *cancelQueueBtn;
@property (nonatomic, strong) UIButton *speakMuteBtn;
@property (nonatomic, strong) UIButton *cameraSwitchBtn;
@property (nonatomic, strong) UIButton *videoModeBtn;
@property (nonatomic, strong) UIButton *rotateBtn;

@property (strong, nonatomic)  UIButton *refreshBtn;
@property (strong, nonatomic)  UIImageView *verifyCodeImg;
@property (strong, nonatomic)  UITextField *verifyText;
@end

@implementation MSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotifications];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor grayColor];
    [self composition];
    [self setSIPAddress];
    [self setVideoView];
    [self doWebChatCall];
    
}

- (void)viewWillAppear:(BOOL)animated{
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
                                             selector:@selector(userLeave:)
                                                 name:CALL_MSG_ON_USER_LEAVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callFail:)
                                                 name:CALL_MSG_ON_FAIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendMsgSuccess)
                                                 name:CHAT_MSG_ON_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendMsgFail:)
                                                 name:CHAT_MSG_ON_FAIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessage:)
                                                 name:CHAT_MSG_ON_RECEIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callIsQueuing:)
                                                 name:CALL_MSG_ON_QUEUING object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueIsCancel:)
                                                 name:CALL_MSG_ON_CANCEL_QUEUE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueTimeOut:)
                                                 name:CALL_MSG_ON_QUEUE_TIMEOUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveQueueInfo:)
                                                 name:CALL_MSG_ON_QUEUE_INFO object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeskShare:)
                                                 name:CALL_MSG_ON_SCREEN_DATA_RECEIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deskShareStop:)
                                                 name:CALL_MSG_ON_SCREEN_SHARE_STOP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showVerifyCode:)
                                                 name:CALL_GET_VERIFY_CODE
                                               object:nil];
}

- (void)callSuccess:(NSNotification *)notify
{
    [self stopCallTimer];
    NSString *result = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.queueinfoText removeFromSuperview];
        [self.cancelQueueBtn removeFromSuperview];
    });
    if ([result isEqualToString:AUDIO_CALL])
    {
        _audioSuccess = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Audio", ""),NSLocalizedString(@"Success", "")] ;
            [self.audionBtn setTitle:NSLocalizedString(@"AudioHangUp", "") forState:UIControlStateNormal];
        });
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        [self videoSuccess];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isWebCall = NO;
            self.remindLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Success", "")];
        });
    }
    _isCalling = NO;
}

- (void)callEnd:(NSNotification *)notify
{
    _isCalling = NO;
    NSString *result = (NSString *)notify.object;
    if ([result isEqualToString:AUDIO_CALL])
    {
        [self stopCallTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Audio", ""),NSLocalizedString(@"CallEnd", "")];
        });
        if (_audioSuccess)
        {
            _audioSuccess = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.audionBtn setTitle:NSLocalizedString(@"Audio", "") forState:UIControlStateNormal];
            });
        }
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        [self videoEnd];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remindLabel.text =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"CallEnd", "")];
        });
    }
}

- (void)userLeave:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remindLabel.text = NSLocalizedString(@"LeaveConf", "");
    });
}

- (void)callFail:(NSNotification *)notify
{
    NSString *result = notify.object;
    [self stopCallTimer];
    if (_isWebCall)
    {
        NSLog(@"web call failed");
        [[CCUtil shareInstance] releaseWebChatCall];
        _isWebCall = NO;
          dispatch_async(dispatch_get_main_queue(), ^{
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@ %@:%@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Fail", ""),result] delegate:self];
          });
    }
    else
    {
        NSLog(@"others call failed");
        dispatch_async(dispatch_get_main_queue(), ^{
                self.remindLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Fail", ""),result];
        });
    }
    _isCalling = NO;
}

- (void)sendMsgSuccess
{
    NSLog(@"send message success");
}

- (void)sendMsgFail:(NSNotification *)notify
{
    NSString *result = (NSString *)notify.object;
    [self.dataArray removeLastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatTableView reloadData];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"SendFailed", ""),result]];
    });
}

- (void)receiveMessage:(NSNotification *)notify
{
    NSString *message = [NSString stringWithFormat:@"%@",(NSString *)notify.object];
    
    NSLog(@"string======%@",message);
    NSString *str5 = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"string======%@",str5);
    
//    [self.dataArray addObject:[message stringByRemovingPercentEncoding]];
    [self.dataArray addObject:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatTableView reloadData];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
    });
}

- (void)callIsQueuing:(NSNotification *)notify
{
    [self stopCallTimer];
    _isWebCall = NO;
    [self startQueueTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remindLabel.text = NSLocalizedString(@"Queue", "");
        [self.view addSubview:self.queueinfoText];
        [self.view addSubview:self.cancelQueueBtn];
    });
}

- (void)queueIsCancel:(NSNotification *)notify
{
    NSLog(@"queueIsCancel");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remindLabel.text =[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"QueueEnd", ""),NSLocalizedString(@"Cancel", "")] ;
        [CCDemoUtil showAlertWithTitle:@"" content:[NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Cancel", ""),NSLocalizedString(@"Queue", "")]  delegate:self];
    });
    _isCalling = NO;
}

- (void)queueTimeOut:(NSNotification *)notify
{
    [self stopQueueTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.queueinfoText.text = @"";
        [self.queueinfoText removeFromSuperview];
        [self.cancelQueueBtn removeFromSuperview];
        self.remindLabel.text = NSLocalizedString(@"QueueTimeOut", "");
         [CCDemoUtil showAlertWithTitle:@"" content:NSLocalizedString(@"QueueTimeOut", "") delegate:self];
    });
    _isCalling = NO;
}

- (void)receiveQueueInfo:(NSNotification *)notify
{
    NSDictionary *queueInfo = (NSDictionary *)notify.userInfo;
   
    if (queueInfo != nil)
    {
         NSString *queueString = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@",NSLocalizedString(@"Position", ""),[queueInfo objectForKey:POSITION_KEY],NSLocalizedString(@"OnlineAgentNum", ""),[queueInfo objectForKey:ONLINEAGENTNUM_KEY],NSLocalizedString(@"LongsWaitTime", ""),[queueInfo objectForKey:LONGESTWAITTIME_KEY]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.queueinfoText.text = queueString;
        });
    }
    else
    {
        [self stopQueueTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remindLabel.text = NSLocalizedString(@"QueueEnd", "");
            [self.queueinfoText removeFromSuperview];
            [self.cancelQueueBtn removeFromSuperview];
        });
    }
}

- (void)receiveDeskShare:(NSNotification *)notify
{
    _screenShare = YES;
}

- (void)deskShareStop:(NSNotification *)notify
{
    _screenShare = NO;
    if (_shareViewOpen)
    {
        _shareViewOpen = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.screenshareView removeFromSuperview];
            [self showView];
        });
    }
}

-(void)startQueueTimer{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _queueTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_queueTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_queueTimer, ^{
        [self getQueueInfo];
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

-(void)startCallTimer{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _callTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_callTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_callTimer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_callTimer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _isCalling = NO;
                if (_isWebCall)
                {
                    [[CCUtil shareInstance] releaseWebChatCall];
                    [CCDemoUtil showAlertWithTitle:@"" content:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"CallTimeOut", "")]  delegate:self];
                }
                else
                {
                    [[CCUtil shareInstance] releaseCall];
                    self.remindLabel.text = NSLocalizedString(@"CallTimeOut", "");
                    [CCDemoUtil showAlertWithTitle:@"" content:NSLocalizedString(@"CallTimeOut", "")];
                }

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


- (void)setSIPAddress{
    [[CCUtil shareInstance] setTransportSecurityUseTLS:NO useSRTP:NO];
    [[CCUtil shareInstance] setSIPServerAddress:[LoginInfo sharedInstance].MSSipIp port:[LoginInfo sharedInstance].MSSipPort];
}

- (void)setVideoView
{
    [[CCUtil shareInstance] setVideoContainer:self.localView remoteView:self.remoteView];
    [[CCUtil shareInstance] setDesktopShareContainer:self.screenshareView];
}

- (void)getQueueInfo
{
    [[CCUtil shareInstance] getCallQueueInfo];
}

- (void)doWebChatCall
{
    NSLog(@"chatAcode : %@",[LoginInfo sharedInstance].MSChatACode);
    [[CCUtil shareInstance] webChatCall:[LoginInfo sharedInstance].MSChatACode callData:[NSString stringWithFormat:@"(CHAT)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:[LoginInfo sharedInstance].VCode];
    _isWebCall = YES;
    [self startCallTimer];
    self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Calling", "")];
    _isCalling = YES;
}

- (void)videoSuccess
{
    _videoSuccess = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoBtn setTitle:NSLocalizedString(@"VideoHangUp", "") forState:UIControlStateNormal];
        [self showView];
        [self.remindLabel removeFromSuperview];
        self.remindLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"Success", "")];
        [self.remoteView addSubview:self.remindLabel];
    });
}

- (void)showView
{
    [self.view addSubview:self.remoteView];
    [self.view addSubview:self.localView];
    [self.view bringSubviewToFront:self.remoteView];
    [self.view bringSubviewToFront:self.localView];
    _videoViewOpen = YES;
}
- (void)closeView
{
    [self.remoteView removeFromSuperview];
    [self.localView removeFromSuperview];
    _videoViewOpen = NO;
}

- (void)videoEnd
{
    _videoSuccess = NO;
    if (_videoViewOpen)
    {
        _videoViewOpen = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self closeView];
        });
    }
    if (_shareViewOpen)
    {
        _shareViewOpen = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.screenshareView removeFromSuperview];
        });
    }
    if (_screenShare)
    {
        _screenShare = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remindLabel removeFromSuperview];
        self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"CallEnd", "")];;
        [self.view addSubview:self.remindLabel];
        [self.videoBtn setTitle:NSLocalizedString(@"Video", "") forState:UIControlStateNormal];
    });
}

- (void)cancelQueue
{
    [[CCUtil shareInstance] cancelQueue];
    [self stopQueueTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.queueinfoText removeFromSuperview];
        [self.cancelQueueBtn removeFromSuperview];
    });
}

- (void)cameraSwitchClick
{
    if (!_videoSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cameraSwitch) object:nil];
    [self performSelector:@selector(cameraSwitch) withObject:nil afterDelay:1.0];
}

- (void)cameraSwitch
{
    _rotate = 0;
    if (_isBackCamera)
    {
        [[CCUtil shareInstance] switchCamera:1];
        _isBackCamera = NO;
         [self.cameraSwitchBtn setTitle:NSLocalizedString(@"FrontCamera", "FrontCam") forState:UIControlStateNormal];
        return;
    }
    [[CCUtil shareInstance] switchCamera:0];
    _isBackCamera = YES;
     [self.cameraSwitchBtn setTitle:NSLocalizedString(@"BackCamera", "BackCam") forState:UIControlStateNormal];
}

- (void)speakMuteClick
{
    if (!_audioSuccess){
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoAudio", "")];
        return;
    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(speakMute) object:nil];
    [self performSelector:@selector(speakMute) withObject:nil afterDelay:1.0];
}
- (void)speakMute
{
    if (_speakIsMute)
    {
        NSLog(@"changeAudioRoute 1");
        [[CCUtil shareInstance] changeAudioRoute:1];
        [self.speakMuteBtn setTitle:NSLocalizedString(@"Receiver", "") forState:UIControlStateNormal];
        _speakIsMute = NO;
        return;
    }
    NSLog(@"changeAudioRoute 0");
    [[CCUtil shareInstance] changeAudioRoute:0];
    [self.speakMuteBtn setTitle:NSLocalizedString(@"Speaker", "") forState:UIControlStateNormal];
    _speakIsMute = YES;
}



- (void)videoModeClick
{
    if (!_videoSuccess)
    {
         [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoMode) object:nil];
    [self performSelector:@selector(videoMode) withObject:nil afterDelay:1.0];
}
- (void)videoMode
{
    if (_isHResolution)
    {
        [[CCUtil shareInstance] setVideoMode:1];
        _isHResolution = NO;
        return;
    }
    [[CCUtil shareInstance] setVideoMode:0];
    _isHResolution = YES;
}

- (void)sendMessageClick
{
    
    if (_isCalling)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Current", "")];
        return;
    }
    if (self.chatText.text.length == 0) {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoMessage", "")];
        return;
    }
    
    NSInteger ret = [[CCUtil shareInstance] sendMsg:self.chatText.text];
    if (ret != RET_OK)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"SendInterface", ""),(long)ret]];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Send", ""),self.chatText.text];
    [self.dataArray addObject:message];
    self.chatText.text = @"";
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)videoCallClick
{
    if (_isCalling)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Current", "")];
        return;
    }
   
    
    if (_videoSuccess)
    {
        [[CCUtil shareInstance] releaseCall];
        _videoSuccess = NO;
        if (_screenShare) {
            _screenShare = NO;
        }
        if (_videoViewOpen)
        {
            _videoViewOpen = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeView];
            });
        }
        if (_shareViewOpen)
        {
            _shareViewOpen = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.screenshareView removeFromSuperview];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.remindLabel removeFromSuperview];
            self.remindLabel.text =[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"CallEnd", "")];
            [self.view addSubview:self.remindLabel];
            [self.videoBtn setTitle:NSLocalizedString(@"Video", "") forState:UIControlStateNormal];
        });
    }
    else
    {
         _isCalling = YES;
        if(_audioSuccess)
        {
            [self startCallTimer];
            self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"Calling", "")];
            [[CCUtil shareInstance] updateToVideo];
        }
        else
        {
            self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"Calling", "")];
//            [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:VIDEO_CALL callData:[NSString stringWithFormat:@"(VIDEO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.verifyText.text mediaAbility:@"1"];
             [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:AUDIO_CALL callData:[NSString stringWithFormat:@"(AUDIO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.self.verifyText.text mediaAbility:@"1"];
        }
    }
}

- (void)audioCallClick
{
//    if (_isCalling)
//    {
//        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Current", "")];
//        return;
//    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(audioCall) object:nil];
    [self performSelector:@selector(audioCall) withObject:nil afterDelay:1.0];
    
   
}

-(void)audioCall
{
    _isCalling = YES;
    
    self.remindLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Audio", ""),NSLocalizedString(@"Calling", "")];
    if (!_audioSuccess)
    {
        [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:AUDIO_CALL callData:[NSString stringWithFormat:@"(AUDIO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.verifyText.text mediaAbility:@"0"];
    }
    else
    {
        [[CCUtil shareInstance] releaseCall];
        if (_videoSuccess)
        {
            _videoSuccess = NO;
            
            if (_screenShare)
            {
                _screenShare = NO;
            }
            if (_videoViewOpen)
            {
                _videoViewOpen = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self closeView];
                });
            }
            
            if (_shareViewOpen)
            {
                _shareViewOpen = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.screenshareView removeFromSuperview];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.remindLabel removeFromSuperview];
                self.remindLabel.text = NSLocalizedString(@"CallEnd", "");
                [self.view addSubview:self.remindLabel];
                [self.videoBtn setTitle:NSLocalizedString(@"Video", "") forState:UIControlStateNormal];
            });
        }
    }
}

- (void)rotateClick
{
    if (!_videoSuccess)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
        return;
    }
    _rotate += 90;
    if (_rotate > 270)
    {
        _rotate = 0;
    }
    [[CCUtil shareInstance] setVideoRotate:_rotate];
}

- (void)shareBtnClick
{
//    if (!_screenShare)
//    {
//        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoShare", "")];
//        return;
//    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(shareDesk) object:nil];
    [self performSelector:@selector(shareDesk) withObject:nil afterDelay:1.0];
}

- (void)shareDesk
{
    if (_shareViewOpen)
    {
        _shareViewOpen = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.screenshareView removeFromSuperview];
            [self showView];
        });
        return;
    }
    _shareViewOpen = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeView];
        [self.view addSubview:self.screenshareView];
    });
}


- (void)backClick
{
    if (_isCalling)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Current", "")];
        return;
    }
    [[CCUtil shareInstance] releaseWebChatCall];
    [[CCUtil shareInstance] releaseCall];
    [[CCUtil shareInstance] logout];
    if (_videoSuccess)
    {
        [self videoEnd];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)composition
{
     self.dataArray = [[NSMutableArray alloc] init];
    _rotate = 0;
    _speakIsMute = YES;
    _count = 0;
    _KWIDTH = kSWIDTH-150;
    _kwidth = (_KWIDTH-60)/4;
    
    self.remoteView = [EAGLView getRemoteVideoViewWithFrame:CGRectMake(0, 0, _KWIDTH, kSHEIGHT - 2*ButtonHeight)];
    self.remoteView.backgroundColor = [UIColor blackColor];
    self.localView = [EAGLView getLocalVideoViewWithFrame:CGRectMake(_KWIDTH - LocalViewWidth, 0, LocalViewWidth, LocalViewHeight)];
    
    self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(_KWIDTH/2-100, 0, 160, 40)];
    self.remindLabel.textColor = [UIColor redColor];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.remindLabel];
    
    CGRect sFrame = self.remoteView.frame;
    self.screenshareView = [[UIImageView alloc] initWithFrame:sFrame];
    self.screenshareView.userInteractionEnabled = YES;
    self.screenshareView.multipleTouchEnabled = YES;
    _oldFrame = self.screenshareView.frame;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.screenshareView addGestureRecognizer:pinchGestureRecognizer];

    self.speakMuteBtn = [CCustom butnWithFrame:CGRectMake(_KWIDTH/4*0, sFrame.size.height+1, _KWIDTH/4-1, ButtonHeight-1) title:NSLocalizedString(@"Speaker", "") fontSize:13];
    [self.speakMuteBtn addTarget:self action:@selector(speakMuteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.speakMuteBtn];
    
    self.rotateBtn = [CCustom butnWithFrame:CGRectMake(_KWIDTH/4*1, sFrame.size.height+1, _KWIDTH/4-1, ButtonHeight-1) title:NSLocalizedString(@"Rotate", "") fontSize:13];
    [self.rotateBtn addTarget:self action:@selector(rotateClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateBtn];
    
    self.cameraSwitchBtn = [CCustom butnWithFrame:CGRectMake(_KWIDTH/4*2, sFrame.size.height+1, _KWIDTH/4-1, ButtonHeight-1) title:NSLocalizedString(@"FrontCamera", "") fontSize:13];
    [self.cameraSwitchBtn addTarget:self action:@selector(cameraSwitchClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraSwitchBtn];
    
    self.videoModeBtn = [CCustom butnWithFrame:CGRectMake(_KWIDTH/4*3, sFrame.size.height+1, _KWIDTH/4-1, ButtonHeight-1) title:NSLocalizedString(@"Mode", "") fontSize:13];
    [self.videoModeBtn addTarget:self action:@selector(videoModeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoModeBtn];
    
    self.queueinfoText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.queueinfoText.textColor = [UIColor redColor];
    self.queueinfoText.editable = NO;
    self.queueinfoText.showsHorizontalScrollIndicator = NO;
    
    self.cancelQueueBtn = [CCustom butnWithFrame:CGRectMake(0, 60, 100, 35) title:NSLocalizedString(@"Cancel", "") fontSize:13];
    [self.cancelQueueBtn addTarget:self action:@selector(cancelQueue) forControlEvents:UIControlEventTouchUpInside];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(_KWIDTH, 40, 149, sFrame.size.height-ButtonHeight)];
    self.chatTableView.userInteractionEnabled = YES;
    self.chatTableView.backgroundColor = [UIColor whiteColor];
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.tableFooterView = [[UIView alloc] init];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.chatTableView];
    
    self.backBtn = [CCustom butnWithFrame:CGRectMake(_KWIDTH, 0, 149, 40) title:NSLocalizedString(@"Back", "") fontSize:18];
    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.chatText = [[UITextField alloc] initWithFrame:CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.size.height + 40, 150, 40)];
    self.chatText.placeholder = NSLocalizedString(@"PlaceHolder", "");
    self.chatText.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.chatText];
    
    self.refreshBtn = [CCustom butnWithFrame:CGRectMake(0, self.speakMuteBtn.frame.origin.y+40 , _kwidth-1, ButtonHeight-1) title:NSLocalizedString(@"GetCode", "") fontSize:13];
     self.verifyCodeImg = [[UIImageView alloc] initWithFrame:self.refreshBtn.frame];
      [self.view addSubview:self.verifyCodeImg];
    [self.refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.refreshBtn];
    
    self.verifyText = [[UITextField alloc] initWithFrame:CGRectMake(_kwidth, self.refreshBtn.frame.origin.y, _kwidth-1, ButtonHeight-1)];
    self.verifyText.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.verifyText];
    
    self.audionBtn = [CCustom butnWithFrame: CGRectMake(_kwidth*2, self.refreshBtn.frame.origin.y, _kwidth-1, ButtonHeight-1) title:NSLocalizedString(@"Audio", "") fontSize:13];
    [self.audionBtn addTarget:self action:@selector(audioCallClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.audionBtn];
    
    self.videoBtn = [CCustom butnWithFrame:CGRectMake(_kwidth*3, self.refreshBtn.frame.origin.y, _kwidth-1, ButtonHeight-1) title:NSLocalizedString(@"Video", "") fontSize:13];
    [self.videoBtn addTarget:self action:@selector(videoCallClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoBtn];
    
    self.shareBtn = [CCustom butnWithFrame:CGRectMake(_kwidth*4, self.refreshBtn.frame.origin.y, 59, ButtonHeight-1) title:NSLocalizedString(@"Share", "") fontSize:13];
    [self.shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareBtn];
    
    self.sendMsgBtn = [CCustom butnWithFrame:CGRectMake(self.chatText.frame.origin.x+1, self.chatText.frame.origin.y+41, 149, ButtonHeight-1) title:NSLocalizedString(@"Send", "") fontSize:15];
    [self.sendMsgBtn addTarget:self action:@selector(sendMessageClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendMsgBtn];
}

- (void)refreshBtnClick{
    [self.refreshBtn setBackgroundColor:[UIColor clearColor]];
    [[CCUtil shareInstance] getVerifyCode];
}

- (void)showVerifyCode:(NSNotification *)notify
{
    if ([notify.object intValue] == 0) {
        NSString *encodedImageStr = [notify.userInfo objectForKey:@"verifyCode"];
        NSData *decodedImageData   =  [[NSData alloc] initWithBase64EncodedString:encodedImageStr options:0];
        
        UIImage *decodedImage= [UIImage imageWithData:decodedImageData];
        
        NSLog(@"===Decoded image size: %@", NSStringFromCGSize(decodedImage.size));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.verifyCodeImg setImage:decodedImage];
            [self.refreshBtn setTitle:@"" forState:UIControlStateNormal];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                                   content:NSLocalizedString(@"GetCodeError", "")];
        });
        
        
    }
    
    
}


- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (self.screenshareView.frame.size.width < _oldFrame.size.width) {
            self.screenshareView.frame = _oldFrame;
        }
        pinchGestureRecognizer.scale = 1;
    }
}

#pragma mark - TableView Meths
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseId = @"reuseID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CCUtil shareInstance] releaseWebChatCall];
        [[CCUtil shareInstance] releaseCall];
        if (_videoSuccess)
        {
            [self videoEnd];
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}


@end

