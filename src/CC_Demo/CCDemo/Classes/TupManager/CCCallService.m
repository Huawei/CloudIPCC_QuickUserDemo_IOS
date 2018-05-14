//
//  CCallServer.m
//  CCSDK
//
//  Created by on 16/4/12.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCCallService.h"
#import "CCDefineHead.h"
#import "CCNotificationsDefine.h"
#import "CCAccountInfo.h"
#import "CCConstantInfo.h"
#include <ifaddrs.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import "CCLogger.h"


static CCCallService *call_Server = nil;
@interface CCCallService()
{
    BOOL _isSetSdpValue;//sdp默认值
    BOOL _isSetTacticValue;//默认流畅优先
    BOOL _hasInitTup;
    EN_VIDEO_OPERATION _currentOperation;
    TUP_UINT32 _cameraRotation;
    TUP_UINT32 _cameraIndex;
    BOOL _isLandspacesRight;
}

@end

@implementation CCCallService

+ (CCCallService *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        if (call_Server == nil)
        {
            call_Server = [[CCCallService alloc] init];
        }
    });
    return call_Server;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self regNotify];
        _cameraRotation = 0;
        _cameraIndex = 1;
        _isLandspacesRight = NO;
        _hasInitTup = NO;
        self.callID = 0;
    }
    return self;
    
}

- (void)regNotify
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChanged)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}
- (void)applicationWillResignActiveNotification
{
    [self videoOperate:STOP];
}
- (void)applicationDidBecomeActiveNotification
{
    [self videoOperate:OPEN|START];
    
}

#pragma mark - UIDeviceOrientation Notify
-(void)orientationDidChanged
{
     if (_currentOperation == STOP)
    {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight:
        {
            _cameraRotation = (_cameraIndex == LocalCameraFront?2:0);
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
             _cameraRotation = (_cameraIndex == LocalCameraFront?0:2);
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            _cameraRotation = 3;//2
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            _cameraRotation = 1;//2
        }
            break;
            
        default:
        {
            _cameraRotation = 3;//2
        }
            break;
    }
    
    [self rotateCaptureWithCallId:self.callID captureIndex:_cameraIndex captureRotation:_cameraRotation videoOperation:START];
}

- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate
{
    if (self.callID == 0)
    {
        return NO;
    }
    TUP_RESULT changeRotate = -1;
    switch (rotate)
    {
        case 0:
        {
            changeRotate = 0;
        }
            break;
        case 90:
        {
            changeRotate = 1;
        }
            break;
        case 180:
        {
            changeRotate = 2;
        }
            break;
        case 270:
        {
            changeRotate = 3;
        }
            break;
        default:
            break;
    }
    if (changeRotate == -1)
    {
        return NO;
    }
    
    TUP_RESULT rotateRet  = tup_call_set_capture_rotation(self.callID, _cameraIndex, changeRotate);
    logDbg(@"tup_call_set_capture_rotation:%d",rotateRet);
    return (rotateRet == TUP_SUCCESS);
}

- (void)rotateCaptureWithCallId:(TUP_UINT32)callId
                   captureIndex:(TUP_UINT32)cameraIndex
                captureRotation:(TUP_UINT32)rotation
                 videoOperation:(EN_VIDEO_OPERATION)operation
{
    tup_call_set_capture_rotation(callId, (TUP_UINT32)cameraIndex, (TUP_UINT32)rotation);
    
    TUP_UINT32 mirrorType = (cameraIndex == 1)?2:0;
    [self setCaptureDisplayAndMirrorType:self.callID renderWindow:CALL_E_VIDEOWND_CALLLOCAL displayType:2 mirrorType:mirrorType];
}

- (void)setCaptureDisplayAndMirrorType:(TUP_UINT32)callID
                                renderWindow:(CALL_E_VIDEOWND_TYPE)renderWindow
                                 displayType:(TUP_UINT32)displayType
                                  mirrorType:(TUP_UINT32)mirrorType
{
    CALL_S_VIDEO_RENDER_INFO renderInfo;
    memset_s(&renderInfo, sizeof(CALL_S_VIDEO_RENDER_INFO), 0, sizeof(CALL_S_VIDEO_RENDER_INFO));
    renderInfo.enRenderType = renderWindow;
    renderInfo.ulDisplaytype = displayType;
    renderInfo.ulMirrortype = mirrorType;
    tup_call_set_video_render(callID, &renderInfo);
}


#pragma mark - Init Tup
- (BOOL)initTup
{
    if (_hasInitTup)
    {
        return NO;
    }
    //开启日志
    tup_call_log_stop();
    
    TUP_UINT32 level = (TUP_UINT32)([CCConstantInfo shareInstance].logLevel);
    if ([CCConstantInfo shareInstance].logLevel == LOG_NONE)
    {
        level = CALL_E_LOG_INFO;
    }
    
    NSLog(@"level %d",level);
   
    tup_call_log_start(level, 5*1024, 2, (TUP_CHAR*)[[CCConstantInfo shareInstance].logPath UTF8String]);
    //初始化业务模块
    TUP_RESULT ret_init = tup_call_init();
    if (ret_init != TUP_SUCCESS)
    {
        logErr(@"tup_call_init failed");
        return NO;
    }
    //注册呼叫业务TUP广播通知
    TUP_RESULT ret_register_process = tup_call_register_process_notifiy((CALL_FN_CALLBACK_PTR)onTupCallNotifications);
    if (ret_register_process != TUP_SUCCESS)
    {
        logErr(@"tup_call_register_process_notifiy failed");
        return NO;
    }
    _hasInitTup = YES;
    return YES;
}

TUP_VOID onTupCallNotifications(TUP_UINT32 msgid, TUP_UINT32 param1, TUP_UINT32 param2, TUP_VOID *data)
{
    [[CCCallService shareInstance] onReceiveNotificationWithMsgid:msgid
                                                       param1:param1
                                                       param2:param2
                                                         data:data];
}
- (void)onReceiveNotificationWithMsgid:(TUP_UINT32)msgid
                                param1:(TUP_UINT32)param1
                                param2:(TUP_UINT32)param2
                                  data:(void *)data
{
    CALL_E_CALL_EVENT notifyEvent = (CALL_E_CALL_EVENT)msgid;
    switch (notifyEvent)
    {
        case CALL_E_EVT_CALL_RTP_CREATED:
        {
            TUP_RESULT setAudioRoute = tup_call_set_mobile_audio_route(CALL_MOBILE_AUDIO_ROUTE_LOUDSPEAKER);
            logDbg(@"setAudioRoute = %d",setAudioRoute);
        }
            break;
        case CALL_E_EVT_MOBILE_ROUTE_CHANGE:
        {
            TUP_UINT32 ulRoute = param2;
            logDbg(@"current route:%d",ulRoute);
        }
            break;
        case CALL_E_EVT_CALL_INIT_FINISH:
        {
            logDbg(@"tup_call_init finish");
        }
            break;
        case CALL_E_EVT_STATISTIC_NETINFO://网络质量统计信息
        {
            CALL_S_STATISTIC_NETINFO netInfo = *(CALL_S_STATISTIC_NETINFO *)data;
            
            TUP_UINT32 lost = netInfo.ulLost;
            TUP_UINT32 delay = netInfo.ulDelay;
            TUP_UINT32 jitter = netInfo.ulJitter;
            logDbg(@"丢包率 ＝ %d,时延 = %d,抖动 = %d",lost,delay,jitter);
        }
            break;
        case CALL_E_EVT_NET_QUALITY_CHANGE: //网络质量改变通知
        {
            CALL_S_NETQUALITY_CHANGE netQuality = *((CALL_S_NETQUALITY_CHANGE *)data);
            TUP_UINT32 netLevel = netQuality.ulNetLevel;
            NSString *levelStr = [NSString stringWithFormat:@"%d",netLevel];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_NET_QUALITY_LEVEL object:levelStr];
        }
            break;
        case CALL_E_EVT_CALL_CONNECTED://通话建立
        {
            self.isConnected = YES;
            if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
            {
                logDbg(@"tp call success");
                [self configLocalView:self.localViewWindow remoteView:self.remoteViewWindow callId:self.callID];
                return;
            }
            logDbg(@"ms audio call success");
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_CONNECTED object:AUDIO_CALL];
        }
            break;
        case CALL_E_EVT_CALL_ENDED://通话结束
        {
            self.isConnected = NO;
            if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
            {
                _cameraRotation = 0;
                _cameraIndex = 1;
                self.callID = 0;
                logDbg(@"tp call end");
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_DISCONNECTED object:nil];
            }
            else
            {
                logDbg(@"ms audio call end");
                if (([CCAccountInfo shareInstance].chatStatus == CHAT_NOT_CONNECTED) && (![CCConfManager shareInstance].isConnected))
                {
                    [CCAccountInfo shareInstance].uvid = @"";
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_DISCONNECTED object:AUDIO_CALL];
            }
           
        }
            break;
        case CALL_E_EVT_SIPACCOUNT_INFO://sip 注册信息
        {
            CALL_S_SIP_ACCOUNT_INFO *regsult = (CALL_S_SIP_ACCOUNT_INFO *)data;
            logDbg(@"sip server info:%s",regsult->acServer);
        }
            break;
            
        case CALL_E_EVT_SPKDEV_VOLUME_CHANGE:
        {
            TUP_UINT32 speakChange = (TUP_UINT32)param1;
            logDbg(@"speak volum change:%d",speakChange);
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Lock Operation
- (void)videoOperate:(EN_VIDEO_OPERATION)operation
{
    // 切后台时，必须stop本端和远端render，否则ios7锁屏会崩溃
    _currentOperation = operation;
    [self controlVideoWithOperation:operation Module:LOCAL_AND_REMOTE];
}

- (void)controlVideoWithOperation:(EN_VIDEO_OPERATION)operation Module:(EN_VIDEO_OPERATION_MODULE)module
{
    if (self.callID == 0)
    {
        return;
    }
    CALL_S_VIDEOCONTROL videoControlInfo;
    memset_s(&videoControlInfo, sizeof(CALL_S_VIDEOCONTROL), 0, sizeof(CALL_S_VIDEOCONTROL));
    videoControlInfo.ulCallID = (TUP_UINT32)self.callID;
    videoControlInfo.ulOperation = operation;
    videoControlInfo.ulModule = module;
    if (STOP == operation)
    {
        videoControlInfo.bIsSync = TUP_TRUE;
    }
    else
    {
        videoControlInfo.bIsSync = TUP_FALSE;
    }
    TUP_RESULT controlRet =  tup_call_video_control(&videoControlInfo);
    logDbg(@"Camera_Log:tup_call_video_control, operation is %d, module is %d ,result is %d",operation,module,controlRet);
}

#pragma mark - 分辨率
- (BOOL)setTacticWithValue:(int)tacticValue
{
    //视频配置:策略 0 图像质量优先  1 流畅优先，默认图像质量优先。
    TUP_UINT32 value = tacticValue;
    TUP_RESULT tacticRet = tup_call_set_cfg(CALL_D_CFG_VIDEO_TACTIC, &value);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_TACTIC:%d",tacticRet);
    _isSetTacticValue = YES;
    return (tacticRet == TUP_SUCCESS);
}

#pragma mark - 码率
- (BOOL)setSdpWithValue:(int)sdpValue
{
    // @param dataRateValue 支持128K,256K,384K,512K,768K
    //视频配置:sdp CT值，取值范围TUP未作限制，产品需要根据实际组网要求配置，默认值0
    TUP_UINT32 value  = -1;
    if (sdpValue <=DATARATEVALUE_128)
    {
        value = DATARATEVALUE_128;
    }
    else if (sdpValue <= DATARATEVALUE_256)
    {
        value = DATARATEVALUE_256;
    }
    else if (sdpValue <= DATARATEVALUE_384)
    {
        value = DATARATEVALUE_384;
    }
    else if (sdpValue <= DATARATEVALUE_512)
    {
        value = DATARATEVALUE_512;
    }
    else
    {
        value = DATARATEVALUE_768;
    }
    TUP_RESULT sdpCtRet = tup_call_set_cfg(CALL_D_CFG_MEDIA_SDP_CT, &value);
    if (sdpCtRet != TUP_SUCCESS)
    {
        logErr(@"tup_call_set_cfg CALL_D_CFG_MEDIA_SDP_CT failed:%d",sdpCtRet);
        return NO;
    }
    //视频码率
    CALL_S_VIDEO_DATARATE videoDatarate;
    memset_s(&videoDatarate, sizeof(CALL_S_VIDEO_DATARATE), 0, sizeof(CALL_S_VIDEO_DATARATE));
    videoDatarate.ulDataRate = 150;
    videoDatarate.ulMaxBw = value;
    videoDatarate.ulMaxDataRate = 2000;
    videoDatarate.ulMinDataRate = 150;
    
    TUP_RESULT dataRateRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_DATARATE , &videoDatarate);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_DATARATE:%d",dataRateRet);
    
    CALL_S_VIDEO_FRAMERATE frameRate;
    frameRate.uiFrameRate = 15;
    frameRate.uiMinFrameRate = 15;
    TUP_RESULT frameRateRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_FRAMERATE , &frameRate);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_FRAMERATE:%d",frameRateRet);

    CALL_S_VIDEO_FRAMESIZE videoFramesize;
    memset_s(&videoFramesize, sizeof(CALL_S_VIDEO_FRAMESIZE), 0, sizeof(CALL_S_VIDEO_FRAMESIZE));
    videoFramesize.uiFramesize = 8;
    videoFramesize.uiMinFramesize = 7;
    videoFramesize.uiDecodeFrameSize = 11;
    
    TUP_RESULT framesizeRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_FRAMESIZE , &videoFramesize);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_FRAMESIZE:%d",framesizeRet);

    _isSetSdpValue = YES;
    return (dataRateRet == TUP_SUCCESS);
}


- (void)setVideoCfg
{
    //视频编解码器加速信息
    CALL_S_VIDEO_HDACCELERATE videoHarcc;
    videoHarcc.ulHdDecoder = 0;
    videoHarcc.ulHdEncoder = 1;
    TUP_RESULT harccRet = tup_call_set_cfg(CALL_D_CFG_VIDEO_HDACCELERATE, &videoHarcc);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_HDACCELERATE:%d",harccRet);
    
    if (!_isSetSdpValue)
    {
        
        [self setSdpWithValue:512];
        //视频配置:sdp CT值，取值范围TUP未作限制，产品需要根据实际组网要求配置，默认值0
       /* TUP_UINT32 sdpValue = 512;
        TUP_RESULT sdpCtRet = tup_call_set_cfg(CALL_D_CFG_MEDIA_SDP_CT, &sdpValue);
        logDbg(@"tup_call_set_cfg CALL_D_CFG_MEDIA_SDP_CT:%d",sdpCtRet);
        //视频码率
        CALL_S_VIDEO_DATARATE videoDatarate;
        memset_s(&videoDatarate, sizeof(CALL_S_VIDEO_DATARATE), 0, sizeof(CALL_S_VIDEO_DATARATE));
        videoDatarate.ulDataRate = 150;
        videoDatarate.ulMaxBw = sdpValue;
        videoDatarate.ulMaxDataRate = 2000;
        videoDatarate.ulMinDataRate = 150;
        
        TUP_RESULT dataRateRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_DATARATE , &videoDatarate);
        logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_DATARATE:%d",dataRateRet);
        
        CALL_S_VIDEO_FRAMERATE frameRate;
        frameRate.uiFrameRate = 15;
        frameRate.uiMinFrameRate = 15;
        TUP_RESULT frameRateRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_FRAMERATE , &frameRate);
        logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_FRAMERATE:%d",frameRateRet);
        
        CALL_S_VIDEO_FRAMESIZE videoFramesize;
        memset_s(&videoFramesize, sizeof(CALL_S_VIDEO_FRAMESIZE), 0, sizeof(CALL_S_VIDEO_FRAMESIZE));
        videoFramesize.uiFramesize = 8;
        videoFramesize.uiMinFramesize = 7;
        videoFramesize.uiDecodeFrameSize = 11;
        
        TUP_RESULT framesizeRet = tup_call_set_cfg( CALL_D_CFG_VIDEO_FRAMESIZE , &videoFramesize);
        logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_FRAMESIZE:%d",framesizeRet);*/
    }
}

- (void)setCfgWith:(NSString *)ip port:(NSString *)port
{
    TUP_UINT32 sipPort = [port intValue];
    //服务器设置
    CALL_S_SERVER_CFG serverCfg;
    memset_s(&serverCfg, sizeof(CALL_S_SERVER_CFG), 0, sizeof(CALL_S_SERVER_CFG));
    strlcpy(serverCfg.server_address, [ip UTF8String], CALL_D_MAX_URL_LENGTH);
    serverCfg.server_port = sipPort;
    
    TUP_RESULT ret_server = tup_call_set_cfg(CALL_D_CFG_SERVER_REG_PRIMARY, &serverCfg);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SERVER_REG_PRIMARY:%d", ret_server);
    
    TUP_RESULT retPro = tup_call_set_cfg(CALL_D_CFG_SERVER_PROXY_PRIMARY, &serverCfg);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SERVER_PROXY_PRIMARY:%d",retPro);
    
    //sip-port设置
    TUP_RESULT ret_port = tup_call_set_cfg(CALL_D_CFG_SIP_PORT, &sipPort);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_PORT:%d", ret_port);
}

- (void)setCfg
{
    CALL_S_IF_INFO IFInfo;
    memset_s(&IFInfo, sizeof(CALL_S_IF_INFO), 0, sizeof(CALL_S_IF_INFO));
    IFInfo.ulType = CALL_E_IP_V4;
    IFInfo.uAddress.ulIPv4 = inet_addr([[CCCommonUtil localIPAddress] UTF8String]);
    TUP_RESULT ret_netaddr = tup_call_set_cfg(CALL_D_CFG_NET_NETADDRESS, &IFInfo);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_NET_NETADDRESS:%d", ret_netaddr);
    
    TUP_BOOL dscpBool = TUP_TRUE;
    TUP_RESULT dscpRet = tup_call_set_cfg(CALL_D_CFG_DSCP_ENABLE, &dscpBool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_DSCP_ENABLE:%d",dscpRet);
    
    TUP_BOOL typebool = TUP_TRUE;
    TUP_RESULT authRet = tup_call_set_cfg(CALL_D_CFG_SIP_SUB_AUTH_TYPE, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_SUB_AUTH_TYPE:%d",authRet);
    
    TUP_UINT32 value1 = 300;
    TUP_RESULT vRet1 = tup_call_set_cfg(CALL_D_CFG_SIP_REGIST_TIMEOUT, &value1);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_REGIST_TIMEOUT:%d",vRet1);
    
    TUP_INT sessValue = 90;
    TUP_RESULT timeoutRet = tup_call_set_cfg(CALL_D_CFG_SIP_SESSIONTIME, &sessValue);
    logDbg(@"tup_call_set_cfg  CALL_D_CFG_SIP_SESSIONTIME:%d",timeoutRet);
    
    TUP_UINT32 value2 = 1800;
    TUP_RESULT vRet2 = tup_call_set_cfg(CALL_D_CFG_SIP_SUBSCRIBE_TIMEOUT, &value2);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_SUBSCRIBE_TIMEOUT:%d",vRet2);

    TUP_UINT32 value3 = 10;
    TUP_RESULT vRet3 = tup_call_set_cfg(CALL_D_CFG_SIP_REREGISTER_TIMEOUT, &value3);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_REREGISTER_TIMEOUT:%d",vRet3);
    
    TUP_RESULT sessRet = tup_call_set_cfg(CALL_D_CFG_SIP_SESSIONTIMER_ENABLE, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_SESSIONTIMER_ENABLE:%d",sessRet);
    
    //抗丢包
    TUP_RESULT errorRet = tup_call_set_cfg(CALL_D_CFG_VIDEO_ERRORCORRECTING, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_ERRORCORRECTING:%d",errorRet);
    
    //丢包重传
    TUP_RESULT arqRet = tup_call_set_cfg(CALL_D_CFG_VIDEO_ARQ, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_ARQ:%d",arqRet);
    
    TUP_RESULT iframeRet = tup_call_set_cfg(CALL_D_CFG_MEDIA_IFRAME_METHOD, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_MEDIA_IFRAME_METHOD:%d",iframeRet);

    TUP_RESULT fluidRet = tup_call_set_cfg(CALL_D_CFG_MEDIA_FLUID_CONTROL, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_MEDIA_FLUID_CONTROL:%d",fluidRet);
    
    //视频配置:是否使能清晰流畅策略表 智真业务需要(0:不使能-UC,1:使能-TE,默认为0)
    TUP_RESULT fluencyRet = tup_call_set_cfg(CALL_D_CFG_VIDEO_CLARITY_FLUENCY_ENABLE, &typebool);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_VIDEO_CLARITY_FLUENCY_ENABLE:%d",fluencyRet);
}


- (void)anoanmousCallWithCallNumber:(NSString *)accessNumber
{
    TUP_UINT32 callid = 0;
    TUP_RESULT callRet = -1;
    if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
    {
        callRet = tup_call_start_anonymous_call(&callid, CALL_E_CALL_TYPE_IPVIDEO, [accessNumber UTF8String]);
    }
    else
    {
        callRet = tup_call_start_anonymous_call(&callid, CALL_E_CALL_TYPE_IPAUDIO, [accessNumber UTF8String]);
    }
    logDbg(@"tup_call_start_anonymous_call:%d",callRet);
    if (callRet != TUP_SUCCESS)
    {
        NSString *msg = [NSString stringWithFormat:@"%ld",(long)RET_ERROR_AGENT_NOT_FREE];
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:msg];
        return;
    }
    logDbg(@"call success callid:%d",callid);
    self.callID = callid;
}

#pragma mark - Anonymous Call
- (void)startAnonymousCallWithAccessNumber:(NSString *)accessNumber andIp:(NSString *)ip andPort:(NSString *)port
{
    CALL_E_TRANSPORTMODE transModel = self.transPortModel;
    TUP_RESULT transRet = tup_call_set_cfg(CALL_D_CFG_SIP_TRANS_MODE, &transModel);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_TRANS_MODE:%d",transRet);
    
    CALL_E_SRTP_MODE srtModel = self.srtpModel;
    TUP_RESULT srtpRet = tup_call_set_cfg(CALL_D_CFG_MEDIA_SRTP_MODE, &srtModel);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_MEDIA_SRTP_MODE:%d",srtpRet);
    
    [self setCfgWith:ip port:port];
    [self setCfg];
    [self setVideoCfg];
    
    
    NSString *callNum = @"AnonymousCard@";
    if (self.anonymousCard.length>0)
    {
        callNum = [NSString stringWithFormat:@"%@@",self.anonymousCard];
    }
    callNum = [callNum stringByAppendingString:[NSString stringWithFormat:@"%@:%@",[CCCommonUtil localIPAddress],port]];
    TUP_RESULT anRet = tup_call_set_cfg(CALL_D_CFG_SIP_ANONYMOUSNUM, (TUP_VOID*)[callNum UTF8String]);
    logDbg(@"tup_call_set_cfg CALL_D_CFG_SIP_ANONYMOUSNUM:%d",anRet);
    [self anoanmousCallWithCallNumber:accessNumber];
}


#pragma mark - Set Video Window
- (void)configLocalView:(id)localView remoteView:(id)remoteView callId:(unsigned int)callId;
{
    //视频窗口信息
    CALL_S_VIDEOWND_INFO videoInfo[2];
    memset_s(videoInfo, sizeof(CALL_S_VIDEOWND_INFO) * 2, 0, sizeof(CALL_S_VIDEOWND_INFO) * 2);
    videoInfo[0].ulVideoWndType = CALL_E_VIDEOWND_CALLLOCAL;
    videoInfo[0].ulRender = (TUP_UPTR)localView;
    videoInfo[1].ulVideoWndType = CALL_E_VIDEOWND_CALLREMOTE;
    videoInfo[1].ulRender = (TUP_UPTR)remoteView;
    
    TUP_RESULT windowRet = tup_call_set_video_window(2, videoInfo, callId);
    logDbg(@"tup_call_set_video_window:%d",windowRet);
    [self orientationDidChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_CONNECTED object:nil];
}

#pragma mark - Switch Camera
- (BOOL)switchVideoOrient:(int)orient
{
    if ((orient == 0 || orient == 1) && (self.callID > 0))
    {
        _cameraIndex = orient;
        [self orientationDidChanged];
        return YES;
    }
    return NO;
}

#pragma mark - Mic Mute
- (BOOL)setMicMute:(BOOL)isMute
{
    if (self.callID == 0)
    {
        return NO;
    }
    TUP_UINT32 callid = self.callID;
    TUP_RESULT muteRet = -1;
    if (isMute)
    {
        muteRet = tup_call_media_mute_mic(callid, 1);
    }
    else
    {
        muteRet = tup_call_media_mute_mic(callid, 0);
    }
    logDbg(@"tup_call_media_mute_mic:%d",muteRet);
    return (muteRet == TUP_SUCCESS);
}

- (BOOL)setSpeakerMute:(BOOL)isMute
{
    if (self.callID == 0)
    {
        return NO;
    }
    TUP_UINT32 callid = self.callID;
    TUP_RESULT muteRet = -1;
    if (isMute)
    {
        muteRet = tup_call_media_mute_speak(callid, true);
    }
    else
    {
        muteRet = tup_call_media_mute_speak(callid, false);
    }
    logDbg(@"tup_call_media_mute_speak:%d",muteRet);
    return (muteRet == TUP_SUCCESS);
}

#pragma mark Video Info
- (Stream_INFO)getStreamInfo
{
    CALL_S_STREAM_INFO callStreamInfo;
    Stream_INFO streamInfo;
    TUP_RESULT streamRet = tup_call_get_callstatics(&callStreamInfo);
    logDbg(@"tup_call_get_channelinfo:%d",streamRet);
    if (streamRet == TUP_SUCCESS)
    {
        CALL_S_VIDEO_STREAM_INFO videoStreamInfo = callStreamInfo.stVideoStreamInfo;
        streamInfo.sendLossFraction = videoStreamInfo.fVideoSendLossFraction;
        streamInfo.sendDelay = videoStreamInfo.fVideoSendDelay;
        streamInfo.receiveLossFraction = videoStreamInfo.fVideoRecvLossFraction;
        streamInfo.receiveDelay = videoStreamInfo.fVideoRecvDelay;
        strlcpy(streamInfo.decodeSize, videoStreamInfo.acDecoderSize, CALL_MAX_FRAMESIZE_LEN);
        strlcpy(streamInfo.encodeSize, videoStreamInfo.acEncoderSize,CALL_MAX_FRAMESIZE_LEN);
        streamInfo.videoWidth = videoStreamInfo.ulWidth;
        streamInfo.videoHeigth = videoStreamInfo.ulHeight;
    }
    return streamInfo;
}

#pragma mark - Speak Set
- (BOOL)setSpeakerVolume:(int)volume
{
    TUP_RESULT setRet = tup_call_media_set_speak_volume(CALL_E_AO_DEV_SPEAKER, volume);
    logDbg(@"tup_call_media_set_speak_volume:%d",setRet);
    return (setRet == TUP_SUCCESS);
}

- (NSInteger)getSpeakerVolume
{
    TUP_UINT32 volume = 0;
    TUP_RESULT volumeRet = tup_call_media_get_speak_volume(&volume);
    logDbg(@"tup_call_media_get_speak_volume:%d",volumeRet);
    return volume;
}

- (BOOL)changeAudioRoute:(int)route
{
    TUP_RESULT routeRes = -1;
    if (route == 0)
    {
        routeRes = tup_call_set_mobile_audio_route(CALL_MBOILE_AUDIO_ROUTE_DEFAULT);
    }
    else if (route == 1)
    {
        routeRes = tup_call_set_mobile_audio_route(CALL_MOBILE_AUDIO_ROUTE_LOUDSPEAKER);
    }
    logDbg(@"tup_call_set_mobile_audio_route:%d",routeRes);
    return (routeRes == TUP_SUCCESS);
}

#pragma mark - End
- (BOOL)releaseCall
{
    TUP_RESULT ret = tup_call_end_call(self.callID);
    return (ret == TUP_SUCCESS);
}

- (void)unInitTup
{
    tup_call_uninit();
    _hasInitTup = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
