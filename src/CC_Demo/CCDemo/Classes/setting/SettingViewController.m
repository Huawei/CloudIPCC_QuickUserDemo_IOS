
//
//  SettingViewController.m
//  Meeting
//
//  Created by huawei on 16/3/10.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"
#import "MSEAGView.h"
#import "EAGLView.h"
#import "CCCallService.h"
//Class CCImpHander;
@interface SettingViewController ()<UIActionSheetDelegate>
{
    dispatch_source_t _callTimer;
    dispatch_source_t _queueTimer;
    BOOL _isCalling;
    BOOL _isWebCall;
    CGFloat _KWIDTH;
    CGFloat _kwidth;
    
}

@property (nonatomic, strong) EAGLView *remoteViewScreen;

@property (nonatomic, strong) EAGLView *localViewScreen;

@property (nonatomic,strong)UIButton *assitBtn;



@end


@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.chatdataArray = [[NSMutableArray alloc] init];
    
    [self addNotifications];
//     [self.view addSubview:self.assitBtn];
}





- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSetConfig];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)clickToAssist
{
    [[CCUtil shareInstance] updateToVideo];
}
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
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
                                             selector:@selector(logoutResult:)
                                                 name:AUTH_MSG_ON_LOGOUT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showVerifyCode:)
                                                 name:CALL_GET_VERIFY_CODE
                                               object:nil];
    
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
                                             selector:@selector(joinMeetingSuccess:)
                                                 name:JOIN_MEETING_SUCCESS object:nil];
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.view.width =SCREEN_WIdTH;
    self.remoteView.height = 160;

}

-(void)onKeyBoardWillShow:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSNumber *duration = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
}


-(void)onKeyBoardWillHide:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSNumber *duration = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
}

- (void)loadSetConfig{
    
    [self.logoutBtn setTitle:NSLocalizedString(@"Logout", @"") forState:UIControlStateNormal];
    [self.statusLab setText:NSLocalizedString(@"Login", @"")];
    self.usernameLab.text = [LoginInfo sharedInstance].loginUser;
    [self.getVCodeBtn setTitle:NSLocalizedString(@"GetCode", "") forState:UIControlStateNormal];
    [self.sendChatTextBtn setTitle:NSLocalizedString(@"Send", "") forState:UIControlStateNormal];
    
    [self.sendChatClickBtn setTitle:NSLocalizedString(@"DoWebChat", "") forState:UIControlStateNormal];
    [self.chatlab setText:NSLocalizedString(@"ChatLab", "")];
    [self.releaseBtn setTitle:NSLocalizedString(@"releasechat", "") forState:UIControlStateNormal];
    [self.releaseCallBtn setTitle:NSLocalizedString(@"releasecall", "") forState:UIControlStateNormal];
    self.chatRecordTabView.userInteractionEnabled = YES;
    self.chatRecordTabView.backgroundColor = [UIColor whiteColor];
    self.chatRecordTabView.delegate = self;
    self.chatRecordTabView.dataSource = self;
    self.chatRecordTabView.tableFooterView = [[UIView alloc] init];
    self.chatRecordTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.getVCodeBtn.enabled = YES;
    self.sendChatClickBtn.enabled = YES;
    self.sendChatTextBtn.enabled = NO;
    [self.callClickBtn setTitle:NSLocalizedString(@"CallClick", "") forState:UIControlStateNormal];
    self.callClickBtn.enabled=YES;
    [self.voiceLab setText:NSLocalizedString(@"Voice", "")];
    [self.videoLab setText:NSLocalizedString(@"Video", "")];
    
    
    //    self.remoteViewScreen = [EAGLView getRemoteVideoViewWithFrame:CGRectMake(0, kSHEIGHT-245, 190, 245)];
    //    self.localViewScreen = [EAGLView getLocalVideoViewWithFrame:CGRectMake(190, kSHEIGHT-245, 190, 245)];
    //    self.remoteViewScreen.userInteractionEnabled = YES;
    //    self.remoteViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    self.localViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //    [self.remoteViewScreen addBlackSublayer];
    //    [self.localViewScreen addBlackSublayer];
    //    [self.view addSubview:self.remoteViewScreen];
    //    [self.view addSubview:self.localViewScreen];
    //    [self.view bringSubviewToFront:self.remoteViewScreen];
    //    [self.view bringSubviewToFront:self.localViewScreen];
    //    [[CCUtil shareInstance] setVideoContainer:self.localViewScreen remoteView:self.remoteViewScreen];
    [[CCUtil shareInstance] getVerifyCode];
    
    
    
}


- (void)logoutResult:(NSNotification *)notify
{
    NSString *logoutResult  = (NSString *)notify.object;
    NSLog(@"logoutResult : %@",logoutResult);
    [[CCUtil shareInstance] releaseCall];
    _isCalling = NO;
    _isWebCall = NO;
    if ( [logoutResult intValue]==SUCCESS_LOGOUT) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self initBtnStatus];
            //退出成功，释放资源，回到主界面
            //[[CCUtil shareInstance] releaseCall];
            [self.remoteViewScreen removeFromSuperview];
            [self.localViewScreen removeFromSuperview];
            
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"LogoutResult", ""),logoutResult]];
        [self.remoteViewScreen removeFromSuperview];
        [self.localViewScreen removeFromSuperview];
        //[self initBtnStatus];
    });
}



- (void)joinMeetingSuccess:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCDemoUtil showAlertSureWithTitle:NSLocalizedString(@"Remind", "")
                               content:@"加入会议成功"];
    });
}

- (void)showVerifyCode:(NSNotification *)notify
{
    if ([notify.object intValue] == 0) {
        NSString *encodedImageStr = [notify.userInfo objectForKey:@"verifyCode"];
        NSData *decodedImageData   =  [[NSData alloc] initWithBase64EncodedString:encodedImageStr options:0];
        UIImage *decodedImage= [UIImage imageWithData:decodedImageData];
        
        NSLog(@"===Decoded image size: %@", NSStringFromCGSize(decodedImage.size));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.verifyCodeImage setImage:decodedImage];
            //[self.refreshBtn setTitle:@"" forState:UIControlStateNormal];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                                   content:NSLocalizedString(@"GetCodeError", "")];
        });
        
        
    }
    
    
}

#pragma mark - TableView Meths
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.chatdataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseId = @"reuseID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = [self.chatdataArray objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:13.0];
    cell.textLabel.font = cellFont;
    cell.textLabel.numberOfLines = 0;
    //CGSize size = CGSizeMake(240,100);
    
    return cell;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 static NSString *reuseId = @"reuseID";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
 }
 cell.textLabel.text = [self.chatdataArray objectAtIndex:indexPath.row];
 //cell.textLabel.numberOfLines=0;
 //cell.lineBreakMode = UILineBreakModeCharacterWrap;
 UIFont *cellFont = [UIFont fontWithName:@"Arial" size:13.0];
 cell.textLabel.font = cellFont;
 CGRect frame = [cell frame];
 cell.textLabel.numberOfLines = 0;
 CGSize size = CGSizeMake(300,100);
 NSDictionary *attr=@{NSFontAttributeName:cellFont};
 CGSize labelsize = [cell.textLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
 cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x,cell.textLabel.frame.origin.y,labelsize.width,labelsize.height);
 frame.size.height = labelsize.height+16;
 cell.frame = frame;
 return cell;
 }
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *cellFont = [UIFont fontWithName:@"Arial" size:13.0];
    NSString *msg = [self.chatdataArray objectAtIndex:indexPath.row];
    NSDictionary *attr=@{NSFontAttributeName:cellFont};
    CGSize size = CGSizeMake(240,100);
    CGSize labelsize = [msg boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    //CGSize labelsize = [msg sizeWithFont:cellFont constrainedToSize:size lineBreakMode:lineBreakmode];
    return labelsize.height+16;
}








#pragma mark-发送消息成功通知
- (void)sendMsgSuccess
{
    NSLog(@"send message success");
}
#pragma mark-发送消息失败通知
- (void)sendMsgFail:(NSNotification *)notify
{
    NSString *result = (NSString *)notify.object;
    [self.chatdataArray removeLastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatRecordTabView reloadData];
        [self.chatRecordTabView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatdataArray.count - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"SendFailed", ""),result]];
    });
}
#pragma mark-收到消息通知
- (void)receiveMessage:(NSNotification *)notify
{
    
    NSString *message = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Receive", ""),notify.object];
    //    [self.chatdataArray addObject:[message stringByRemovingPercentEncoding]];
    [self.chatdataArray addObject:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatRecordTabView reloadData];
        [self.chatRecordTabView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatdataArray.count - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
    });
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
                    self.statusLab.text = NSLocalizedString(@"CallTimeOut", "");
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
#pragma mark-呼叫成功点击通话成功通知
- (void)callSuccess:(NSNotification *)notify
{
    [self stopCallTimer];
    
    
    NSString *result = notify.object;
    
    if ([result isEqualToString:AUDIO_CALL])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"audio call success");
            if (self.videoSwtich.on)
            {
                //                [self.remoteViewScreen deleteBlackSublayer];
                //                [self.localViewScreen deleteBlackSublayer];
            }
            self.statusLab.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Audio", "")] ;
        });
        
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"video call success");
            self.statusLab.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Video", "")] ;
            
        });
    }
    else
    {
        NSLog(@"chat success reslut:%@",result);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_isWebCall)
            {
                self.statusLab.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"ChatSuccess", "")];
                self.sendChatTextBtn.enabled = YES;
                self.sendChatClickBtn.enabled = NO;
                _isWebCall = NO;
            }
        });
    }
    _isCalling = NO;
}
#pragma mark-呼叫结束通知
- (void)callEnd:(NSNotification *)notify
{
    _isCalling = NO;
    NSString *result = (NSString *)notify.object;
    if ([result isEqualToString:AUDIO_CALL])
    {
        [self stopCallTimer];
        NSLog(@"call audio end");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLab.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Audio", ""),NSLocalizedString(@"CallEnd", "")];
            self.callClickBtn.enabled = YES;
            
            //            [self.remoteViewScreen addBlackSublayer];
            //            [self.localViewScreen addBlackSublayer];
        });
        /* if (_audioSuccess)
         {
         _audioSuccess = NO;
         dispatch_async(dispatch_get_main_queue(), ^{
         [self.audionBtn setTitle:NSLocalizedString(@"Audio", "") forState:UIControlStateNormal];
         });当前已有呼叫
         }
         */
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        //[self videoEnd];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callClickBtn.enabled = YES;
            self.statusLab.text = [[NSString alloc] initWithFormat:@"%@ %@",NSLocalizedString(@"Video", ""),NSLocalizedString(@"CallEnd", "")];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLab.text =  [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"CallEnd", "")];
            self.getVCodeBtn.enabled = YES;
            self.sendChatClickBtn.enabled = YES;
            self.sendChatTextBtn.enabled = NO;
            
        });
        
    }
}

- (void)userLeave:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLab.text = NSLocalizedString(@"LeaveConf", "");
    });
}

- (void)callFail:(NSNotification *)notify
{
    NSString *result = notify.object;
    [self stopCallTimer];
    if (_isWebCall)
    {
        [[CCUtil shareInstance] releaseWebChatCall];
        _isWebCall = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                                   content:[NSString stringWithFormat:@"%@ %@:%@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Fail", ""),NSLocalizedString(result, "")] delegate:self];
            self.getVCodeBtn.enabled = YES;
            self.sendChatClickBtn.enabled = YES;
            
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLab.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Fail", ""),result];
        });
    }
    _isCalling = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callClickBtn.enabled = YES;
    });
    
}


- (void)callIsQueuing:(NSNotification *)notify
{
    [self stopCallTimer];
    //_isWebCall = NO;
    [self startQueueTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLab.text = NSLocalizedString(@"Queue", "");
        //[self.view addSubview:self.queueinfoText];
        //[self.view addSubview:self.cancelQueueBtn];
    });
}

- (void)queueIsCancel:(NSNotification *)notify
{
    NSLog(@"queueIsCancel");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLab.text =[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"QueueEnd", ""),NSLocalizedString(@"Cancel", "")] ;
        [CCDemoUtil showAlertWithTitle:@"" content:[NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"Chat", ""),NSLocalizedString(@"Cancel", ""),NSLocalizedString(@"Queue", "")]  delegate:self];
        self.callClickBtn.enabled = YES;
        self.sendChatTextBtn.enabled = YES;
    });
    
    _isCalling = NO;
}

- (void)queueTimeOut:(NSNotification *)notify
{
    [self stopQueueTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.queueinfoText.text = @"";
        //[self.queueinfoText removeFromSuperview];
        //[self.cancelQueueBtn removeFromSuperview];
        self.statusLab.text = NSLocalizedString(@"QueueTimeOut", "");
        [CCDemoUtil showAlertWithTitle:@"" content:NSLocalizedString(@"QueueTimeOut", "") delegate:self];
        self.callClickBtn.enabled = YES;
        self.sendChatTextBtn.enabled = YES;
    });
    _isCalling = NO;
}

- (void)receiveQueueInfo:(NSNotification *)notify
{
    NSDictionary *queueInfo = (NSDictionary *)notify.userInfo;
    
    if (queueInfo != nil)
    {
        NSString *queueString = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@",NSLocalizedString(@"Position", ""),[queueInfo objectForKey:POSITION_KEY],NSLocalizedString(@"OnlineAgentNum", ""),[queueInfo objectForKey:ONLINEAGENTNUM_KEY],NSLocalizedString(@"LongsWaitTime", ""),[queueInfo objectForKey:LONGESTWAITTIME_KEY]];
        /* dispatch_async(dispatch_get_main_queue(), ^{
         self.queueinfoText.text = queueString;
         }); */
    }
    else
    {
        [self stopQueueTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLab.text = NSLocalizedString(@"QueueEnd", "");
            // [self.queueinfoText removeFromSuperview];
            // [self.cancelQueueBtn removeFromSuperview];
        });
    }
}

- (void)getQueueInfo
{
    [[CCUtil shareInstance] getCallQueueInfo];
}

- (IBAction)clickJoinMeeting:(id)sender {
     [[CCUtil shareInstance] updateToVideo];
}

- (IBAction)logoutClick:(id)sender {
    //[self disableBtnStatus];
    [[CCUtil shareInstance] logout];
    [[CCUtil shareInstance] releaseWebChatCall];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];});
    
    
}

- (IBAction)releaseCallClick:(id)sender {
    
    if (self.callClickBtn.enabled) {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"release", "") content:NSLocalizedString(@"Nothing to release", "")];
    }else{
        [[CCUtil shareInstance] releaseCall];
        NSLog(@"release chat");
    }
}

- (IBAction)releaseClick:(id)sender {
    if (self.sendChatClickBtn.enabled) {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"release", "") content:NSLocalizedString(@"Nothing to release", "")];
    }else{
        [[CCUtil shareInstance] releaseWebChatCall];
        NSLog(@"release chat");
    }
//    if (!self.sendChatClickBtn.enabled && self.callClickBtn.enabled) {
//        //release chat
//        [[CCUtil shareInstance] releaseWebChatCall];
//        NSLog(@"release chat");
//    }
////    if (!self.callClickBtn.enabled && self.sendChatClickBtn.enabled) {
////        //release call
////        [[CCUtil shareInstance] releaseCall];
////        NSLog(@"release call");
////    }
//    if (!self.sendChatClickBtn.enabled && !self.callClickBtn.enabled) {
//        //release call and chat
////        [[CCUtil shareInstance] releaseCall];
////        [[CCUtil shareInstance] releaseWebChatCall];
//
//    }
}

- (IBAction)getVCodeClick:(id)sender {
    [[CCUtil shareInstance] getVerifyCode];
}
#pragma mark-发起文字呼叫
- (IBAction)sendChatClick:(id)sender {
    NSLog(@"chatAcode : %@ vcode : %@",[LoginInfo sharedInstance].MSChatACode,[LoginInfo sharedInstance].VCode);
    [LoginInfo sharedInstance].VCode = self.verifyCodeText.text;
    [[CCUtil shareInstance] webChatCall:[LoginInfo sharedInstance].MSChatACode callData:[NSString stringWithFormat:@"(CHAT)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:[LoginInfo sharedInstance].VCode];
    _isWebCall = YES;
    [self startCallTimer];
    self.statusLab.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Chat", "")];
    _isCalling = YES;
    //self.getVCodeBtn.enabled = NO;
    //self.sendChatClickBtn.enabled = NO;
    
}
#pragma mark-发送
- (IBAction)sendChatTextClick:(id)sender {
    
    
    if (self.inputChatText.text.length == 0) {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoMessage", "")];
        return;
    }
    
    NSInteger ret = [[CCUtil shareInstance] sendMsg:self.inputChatText.text];
    if (ret != RET_OK)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"SendInterface", ""),(long)ret]];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Send", ""),self.inputChatText.text];
    [self.chatdataArray addObject:message];
    self.inputChatText.text = @"";
    [self.chatRecordTabView reloadData];
    [self.chatRecordTabView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatdataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
#pragma mark-点击通话
- (IBAction)callClick:(id)sender {
    
    if (_isCalling)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Current", "")];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"语音呼叫" otherButtonTitles:@"视频呼叫", nil];
    //actionSheet样式
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    //显示
    [sheet showInView:self.view];
    sheet.delegate = self;
    
//    [LoginInfo sharedInstance].VCode = self.verifyCodeText.text;
//
//    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(audioCall) object:nil];
//    [self performSelector:@selector(audioCall) withObject:nil afterDelay:1.0];
//    self.callClickBtn.enabled = NO;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 8_3) __TVOS_PROHIBITED  // after animation
{
    
        if(buttonIndex==0)
        {
             //语音
            [LoginInfo sharedInstance].VCode = self.verifyCodeText.text;
            
            self.callClickBtn.enabled = NO;
            
            _isCalling = YES;
            NSString *mediaAbility = @"0";
            [CCCallService shareInstance].isVediocall = NO;
             [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:AUDIO_CALL callData:[NSString stringWithFormat:@"(AUDIO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.verifyCodeText.text mediaAbility:mediaAbility];
        }else if(buttonIndex == 1){
            //视频
            [LoginInfo sharedInstance].VCode = self.verifyCodeText.text;
            self.callClickBtn.enabled = NO;
            _isCalling = YES;
            NSString *mediaAbility = @"1";
            [CCCallService shareInstance].isVediocall = NO;
            [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:AUDIO_CALL callData:[NSString stringWithFormat:@"(AUDIO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.verifyCodeText.text mediaAbility:mediaAbility];
            
        }else{
            
        }
}

-(void)audioCall
{
    _isCalling = YES;
    NSString *mediaAbility = @"0";
    
    if (self.videoSwtich.on)
    {
        mediaAbility = @"1";
     [CCCallService shareInstance].isVediocall = YES;
    }else{
        [CCCallService shareInstance].isVediocall = NO;
    }
    
    [[CCUtil shareInstance] makeCall:[LoginInfo sharedInstance].MSAudioACode callType:AUDIO_CALL callData:[NSString stringWithFormat:@"(AUDIO CALL)%@",[LoginInfo sharedInstance].MSCallData] verifyCode:self.verifyCodeText.text mediaAbility:mediaAbility];
    
}


- (IBAction)vedioSwtichClick:(id)sender {
    if(self.videoSwtich.on)
    {
        [self.vocieSwtich setOn:NO];
    }
    else
    {
        [self.vocieSwtich setOn:YES];
        
    }
}

- (IBAction)voiceSwitchClick:(id)sender {
    
    if(self.vocieSwtich.on)
    {
        [self.videoSwtich setOn:NO];
    }
    else
    {
        [self.videoSwtich setOn:YES];
        
    }
    
}
- (UIButton *)assitBtn
{
    if (!_assitBtn) {
        _assitBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, 100, 40)];
        [_assitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_assitBtn setTitle:@"加入会议" forState:UIControlStateNormal];
        _assitBtn.layer.borderWidth = 1.0;
        _assitBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _assitBtn.layer.masksToBounds = YES;
        _assitBtn.layer.cornerRadius = 5.0;
        [_assitBtn addTarget:self action:@selector(clickToAssist) forControlEvents:UIControlEventTouchUpInside];
    }
    return _assitBtn;
}
@end
