//
//  CConfManager.m
//  CCUtil
//
//  Created by on 16/5/9.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCConfManager.h"
#import "CCDefineHead.h"
#import "CCAccountInfo.h"
#import "CCNotificationsDefine.h"
#import "CCCommonUtil.h"
#import "CCCallService.h"
#import "CCConstantInfo.h"
#import "CCLogger.h"

#import "tup_def.h"
#import "call_interface.h"
#import "tup_conf_baseapi.h"
#import "tup_conf_extendapi.h"
#import "tup_conf_otherapi.h"


enum {
    ANNOTCUSTOMER_PICTURE,
    ANNOTCUSTOMER_MARK,
    ANNOTCUSTOMER_POINTER,
    
    CUSTOMER_ANNOT_COUNT
};

enum {
    LOCALRES_CHECK,
    LOCALRES_XCHECK,
    LOCALRES_LEFTPOINTER,
    LOCALRES_RIGHTPOINTER,
    LOCALRES_UPPOINTER,
    LOCALRES_DOWNPOINTER,
    LOCALRES_LASERPOINTER,
    
    LOCALRES_COUNT
};


@interface CCConfManager ()
{
    dispatch_source_t _heartBeatTimer;
    CONF_HANDLE _confHandle;
    BOOL _hasCreateConf;
    BOOL _isInConf;
    BOOL _localCameraIsOpen;
    BOOL _hasInit;
    BOOL _isQuality;
    TUP_UINT32 _cameraRotation;
    TUP_UINT32 _cameraIndex;
    BOOL _localAttached;
    BOOL _remoteAttached;
    BOOL _isLandspacesRight;
    
}

@end


@implementation CCConfManager

+ (CCConfManager *)shareInstance
{
    static CCConfManager *conf_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        if (conf_manager == nil)
        {
            conf_manager = [[CCConfManager alloc] init];
        }
    });
    return conf_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self regNotify];
        _confHandle = 0;
        _selfDeviceID = 1;
        _selfUserID = 0;
        _cameraIndex = 1;
        _localCameraInfo = [[CCConfCameraInfo alloc] init];
        _localCameraInfo.deviceID = 0;
        _remoteCameraInfo = [[CCConfCameraInfo alloc] init];
        _remoteCameraInfo.deviceID = 0;
        self.cameraInfoArray = [[NSMutableArray alloc] init];
        self.confUserArray = [[NSMutableArray alloc] init];
        _screenView = nil;
        _fileView = nil;
        _isLandspacesRight = NO;
    }
    return self;
}

- (void)regNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIApplicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIApplicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)initConf
{
    if (_hasInit)
    {
        return;
    }
    Init_param initParam;
    memset_s(&initParam, sizeof(Init_param), 0, sizeof(Init_param));
    initParam.os_type = CONF_OS_IOS;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        initParam.dev_type = CONF_DEV_PHONE;
    }
    else
    {
        initParam.dev_type = CONF_DEV_PAD;
    }
    initParam.dev_dpi_x = 0;
    initParam.dev_dpi_y = 0;
    initParam.conf_mode = 0;
    initParam.sdk_log_level = [CCConstantInfo shareInstance].logLevel;
    initParam.media_log_level = [CCConstantInfo shareInstance].logLevel;
    
    if ([CCConstantInfo shareInstance].logPath.length>0) {
        strlcpy(initParam.log_path, [[CCConstantInfo shareInstance].logPath UTF8String], TC_MAX_PATH);
        strlcpy(initParam.temp_path, [[CCConstantInfo shareInstance].logPath UTF8String], TC_MAX_PATH);
    }
    
    tup_conf_init(false, &initParam);
    _hasInit = YES;
}


-(void)orientationChanged
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight:
        {
            _cameraRotation = (_cameraIndex == LocalCameraFront?180:0);
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            _cameraRotation = (_cameraIndex == LocalCameraFront?0:180);
        }
            break;
        case UIDeviceOrientationPortrait:
        {
             _cameraRotation = 270;//180
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
              _cameraRotation = 90;//180
        }
            break;
            
        default:
        {
              _cameraRotation = 270;//180
        }
            break;
    }

    tup_conf_video_set_capture_rotate(_confHandle, self.selfDeviceID, _cameraRotation);
}


- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate
{
    if (_confHandle == 0)
    {
        return NO;
    }
    TUP_RESULT rotateRet = tup_conf_video_set_capture_rotate(_confHandle, self.selfDeviceID, rotate);
    logDbg(@"tup_conf_video_set_capture_rotate:%d",rotateRet);
    return (rotateRet == TUP_SUCCESS);
}

- (void)unInitConf
{
    tup_conf_uninit();
    _hasInit = NO;
}

- (void)callWith:(NSString *)ip port:(NSString *)port callNum:(NSString *)callNum
{
    [[CCCallService shareInstance] startAnonymousCallWithAccessNumber:callNum andIp:ip andPort:port];
}

- (void)heartBeatTimerPrc
{
    logDbg(@"tup_conf_heart");
    tup_conf_heart(_confHandle);
}




#pragma mark ------ Create Join Leave
- (BOOL)createConfWithInfo:(CCConfInfo *)info
{
    
    TC_CONF_INFO confInfo;
    memset_s(&confInfo, sizeof(TC_CONF_INFO), 0, sizeof(TC_CONF_INFO));
    confInfo.conf_id = info.confId;
    confInfo.user_id = info.userId;
    confInfo.user_type = info.userType;
    confInfo.user_capability = 0;
    confInfo.sever_timer = 0;
    strlcpy(confInfo.host_key, [info.hostKey UTF8String], TC_MAX_HOST_KEY_LEN);
    strlcpy(confInfo.site_url, [info.siteUrl UTF8String], TC_MAX_SITE_URL_LEN);
    strlcpy(confInfo.site_id, [info.siteId UTF8String], TC_MAX_CONF_SITE_ID_LEN);
    strlcpy(confInfo.user_name, [info.userName UTF8String], TC_MAX_USER_NAME_LEN);
    strlcpy(confInfo.conf_title, [info.confTitle UTF8String], TC_MAX_CONF_TITLE_LEN);
    strlcpy(confInfo.ms_server_ip, [info.msServerIp UTF8String], TC_MAX_CONF_SERVER_IP);
    strlcpy(confInfo.encryption_key, [info.encryptKey UTF8String], TC_MAX_ENCRYPTION_KEY);
    strlcpy(confInfo.user_log_uri, [info.logUri UTF8String], TC_MAX_USER_LOG_URI_LEN);
    
    TUP_UINT32 option = CONF_OPTION_USERLIST;
    option |= CONF_OPTION_LOAD_BALANCING;
    option |= CONF_OPTION_FLOW_CONTROL;
    
    TUP_RESULT confRet = tup_conf_new((conference_multi_callback)ConfCallBack, &confInfo, option, &_confHandle);
    logDbg(@"tup_conf_new:%d",confRet);
    return (confRet == TC_OK);
}

- (void)startHeartBeat
{

    dispatch_queue_t queue = dispatch_get_main_queue();
    _heartBeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_heartBeatTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_heartBeatTimer, ^{
        [self heartBeatTimerPrc];
    });
    
    dispatch_source_set_cancel_handler(_heartBeatTimer, ^{
        _heartBeatTimer =nil;
       
    });
    dispatch_resume(_heartBeatTimer);
}

- (BOOL)joinConf
{
    [self startHeartBeat];
    TUP_RESULT ipRet = tup_conf_setiplist(_confHandle, [self.msServerIp UTF8String]);
    logDbg(@"tup_conf_setiplis:%d",ipRet);
    if (self.isNat)
    {
        IP_NAT_MAP ipmapArray[1];
        memset_s((void *)(&ipmapArray), sizeof(IP_NAT_MAP), 0, sizeof(IP_NAT_MAP));
        const char * innerIPCstr = [self.innerIp UTF8String];
        const char * outerIPCstr = [self.outerIp UTF8String];
        strlcpy(ipmapArray[0].inter_ip, innerIPCstr, sizeof(ipmapArray[0].inter_ip));
        ipmapArray[0].inter_ip[TC_MAX_CONF_SERVER_IP -1] = NULL;
        strlcpy(ipmapArray[0].outer_ip, outerIPCstr, sizeof(ipmapArray[0].outer_ip));
        ipmapArray[0].outer_ip[TC_MAX_CONF_SERVER_IP - 1] = NULL;
        logDbg(@"ipmapArray---%s,%s",ipmapArray[0].inter_ip,ipmapArray[0].outer_ip);
        tup_conf_setipmap(_confHandle, ipmapArray, 1);
    }
    TUP_RESULT joinRet = tup_conf_join(_confHandle);
    logDbg(@"tup_conf_join:%d",joinRet);
    return (joinRet == TC_OK);
}


- (BOOL)setVideoMode:(int)mValue
{
    if (_confHandle == 0)
    {
        return NO;
    }
    TC_VIDEO_PARAM vParam;
    memset_s(&vParam, sizeof(TC_VIDEO_PARAM), 0, sizeof(TC_VIDEO_PARAM));
    TUP_RESULT setRes = -1;
    if (mValue == 0)
    {
        vParam.xResolution = 640;
        vParam.yResolution = 480;
        vParam.nFrameRate = 15;
        _isQuality = YES;
    }
    else
    {
        vParam.xResolution = 352;
        vParam.yResolution = 288;
        vParam.nFrameRate = 30;
        _isQuality = NO;
    }
    setRes = tup_conf_video_setparam(_confHandle, self.selfDeviceID, &vParam);
    [self orientationChanged];
    return (setRes == TC_OK);
}

- (Stream_INFO)getVideoInfo
{
    TC_VIDEO_PARAM pvParam;
    Stream_INFO streamInfo;
    TUP_RESULT paramRes = tup_conf_video_getparam(_confHandle, self.selfDeviceID, &pvParam);
    logDbg(@"tup_conf_video_getparam:%d",paramRes);
    if (paramRes == TC_OK)
    {
        streamInfo.videoWidth = pvParam.xResolution;
        streamInfo.videoHeigth= pvParam.yResolution;
        streamInfo.frameRate = pvParam.nFrameRate;
        streamInfo.bitRate = pvParam.nBitRate;
    }
    return streamInfo;
}

- (BOOL)leaveConf
{
    logDbg(@"leave conf");
    int tRet = tup_conf_leave(_confHandle);
    if (tRet == TC_OK)
    {
        self.isConnected = NO;
        if ((![CCCallService shareInstance].isConnected) && ([CCAccountInfo shareInstance].chatStatus == CHAT_NOT_CONNECTED))
        {
            [CCAccountInfo shareInstance].uvid = @"";
        }
        [self uninitInfo];
    }
    return (tRet == TC_OK);
}

- (BOOL)terminalConf
{
    int tRet = tup_conf_terminate(_confHandle);
    if (tRet == TC_OK)
    {
        self.isConnected = NO;
        [self uninitInfo];
        [[CCICSService shareInstance] stopMeeting];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"terminalCall" object:nil];
        tup_conf_release(_confHandle);
    }
    return (tRet == TC_OK);
}

- (void)stopHeartBeatTimer
{
    if (_heartBeatTimer)
    {
        dispatch_source_cancel(_heartBeatTimer);
    }
}


- (void)uninitInfo
{
    if (_localCameraIsOpen)
    {
        CCConfCameraInfo *info = (CCConfCameraInfo *)[self.cameraInfoArray objectAtIndex:_cameraIndex];
        TUP_RESULT ret = tup_conf_video_close(_confHandle, info.deviceID);
        if (ret)
        {
            _localCameraIsOpen = NO;
        }
    }
    [self stopHeartBeatTimer];
    _isInConf = NO;
    _confHandle = 0;
    _selfDeviceID = 0;
    _selfUserID = 0;
    _localCameraIsOpen = NO;
    _cameraIndex = 1;
    _isQuality = NO;
    _remoteCameraInfo.deviceID = 0;
    _localCameraInfo.deviceID = 0;
    _localAttached = NO;
    _remoteAttached = NO;
    [self.cameraInfoArray removeAllObjects];
    [self.confUserArray removeAllObjects];
}

#pragma mark ------ Conf Call Back
/**
 *  会议回调函数
 *
 */
TUP_VOID ConfCallBack(CONF_HANDLE confHandle, TUP_INT nType, TUP_UINT nValue1, TUP_ULONG nValue2, TUP_VOID* pVoid, TUP_INT nSize)
{
    [[CCConfManager shareInstance] dealConfCallBackWithConfHandle:confHandle
                                                           nType:nType
                                                         nValue1:nValue1
                                                         nValue2:nValue2
                                                            data:pVoid
                                                           nSize:nSize];
}
- (void)dealConfCallBackWithConfHandle:(CONF_HANDLE)confHandle
                                 nType:(TUP_INT)nType
                               nValue1:(TUP_UINT)nValue1
                               nValue2:(TUP_ULONG)nValue2
                                  data:(void *)data
                                 nSize:(TUP_INT)nSize
{
    logDbg(@"dealConfCallBackWithConfHandle,handle:%d",confHandle);
    switch (nType)
    {
        case CONF_MSG_ON_CONFERENCE_JOIN://入会
        {
            [self handleJoinConfWithValue1:nValue1 Value2:nValue2 data:data size:nSize];
        }
            break;
        case CONF_MSG_ON_COMPONENT_LOAD://组件加载成功
        {
            [self handleComponetLoadWithValue1:nValue1 value2:nValue2 data:data size:nSize];
        }
            break;
        case CONF_MSG_USER_ON_ENTER_IND://用户加入
        {
            [self handleUserJoinConfWithValue1:nValue1 Value2:nValue2 data:data size:nSize];
        }
            break;
        case CONF_MSG_ON_CONFERENCE_TERMINATE://会议结束通知
        {
            logDbg(@"MS conf end");
            self.isConnected = NO;
            if ((![CCCallService shareInstance].isConnected) && ([CCAccountInfo shareInstance].chatStatus == CHAT_NOT_CONNECTED))
            {
               [CCAccountInfo shareInstance].uvid = @"";
            }
            [[CCICSService shareInstance] stopMeeting];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"releaseConf" object:nil];
            tup_conf_release(_confHandle);
            [self uninitInfo];
        }
            break;
        case CONF_MSG_USER_ON_LEAVE_IND: //用户离开
        {
            [self handleUserLeaveConfWithValue1:nValue1 Value2:nValue2 data:data size:nSize];
            
        }
            break;
        case CONF_MSG_ON_CONFERENCE_LEAVE:
            break;
        default:
            break;
    }
}

- (void)handleJoinConfWithValue1:(TUP_UINT)value1 Value2:(TUP_ULONG)value2 data:(void *)data size:(TUP_INT)size
{
    logDbg(@"handleJoinConfWithValue1:%d,Value2:%lu,size:%d",value1,value2,size);
    TUP_INT joinRet = value1;
    if (joinRet == TC_OK)
    {
        //入会成功
        _isInConf = YES;
        self.isConnected = YES;
//        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_CONNECTED object:VIDEO_CALL];
        logDbg(@"join conf success");
        tup_conf_get_server_time(_confHandle);
        
        TUP_UINT32 confComponents = IID_COMPONENT_BASE | IID_COMPONENT_DS | IID_COMPONENT_AS | IID_COMPONENT_VIDEO;
        TUP_RESULT loadRet = tup_conf_load_component(_confHandle, confComponents);
        logDbg(@"tup_conf_load_component,confComponents=%d,result=%d",confComponents,loadRet);
        [self registComponentsCallBackWithComponentID:confComponents];
        return;
    }
    logErr(@"join conf failed,joinRet=%d",joinRet);
    NSString *joinFailRe = [NSString stringWithFormat:@"%d",joinRet];
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:joinFailRe];
}

/**
 *  组件加载之后的回调处理逻辑
 *
 *  @param nValue1 组件注册返回值,返回值见TC_RESULT的定义
 *  @param nValue2 组件ID
 *  @param data   NULL
 *  @param size  无参考意义
 */
-(void)handleComponetLoadWithValue1:(TUP_UINT)nValue1 value2:(TUP_ULONG)nValue2 data:(void*)data size:(TUP_INT)size
{
    logDbg(@"handleComponetLoadWithValue1:%d,value2:%lu,size:%d",nValue1,nValue2,size);
    COMPONENT_IID componentID = (COMPONENT_IID)nValue2;
    switch (componentID)
    {
        case IID_COMPONENT_VIDEO:
        {
            logDbg(@"get device info");
            TUP_UINT32 videoDeviceCount = 0;
            tup_conf_video_get_deviceinfo(_confHandle, NULL, &videoDeviceCount);
            TC_DEVICE_INFO *deviceInfo = NULL;
            if (videoDeviceCount > 0)
            {
                deviceInfo = (TC_DEVICE_INFO *)malloc(videoDeviceCount*sizeof(TC_DEVICE_INFO));
            }
            if (deviceInfo != NULL)
            {
                //获取摄像头信息
                tup_conf_video_get_deviceinfo(_confHandle, deviceInfo, &videoDeviceCount);
                for (int i = 0; i < videoDeviceCount; i++)
                {
                    CCConfCameraInfo *cameraInfo = [[CCConfCameraInfo alloc] init];
                    cameraInfo.userID = deviceInfo[i]._UserID;
                    cameraInfo.deviceID = deviceInfo[i]._DeviceID;
                    cameraInfo.deviceName = [NSString stringWithUTF8String:deviceInfo[i]._szName];
                    cameraInfo.videoView = self.localWindowView;
                    cameraInfo.deviceType = deviceInfo[i]._DeviceType;
                    [self.cameraInfoArray addObject:cameraInfo];
                }
                free(deviceInfo);
                [self openLocalCamera];
            }
        }
            break;
            
        case IID_COMPONENT_DS:
        {
        }
            break;
            
        default:
            break;
    }
}

- (void)handleUserJoinConfWithValue1:(TUP_UINT)value1 Value2:(TUP_ULONG)value2 data:(void *)data size:(TUP_INT)size
{
    logDbg(@"handleUserJoinConfWithValue1:%d,Value2:%lu,size:%d",value1,value2,size);
//    入会者信息存到数组中
    TC_Conf_User_Record *joinUserInfo = (TC_Conf_User_Record *)data;
    CCConfUserInfo *user = [[CCConfUserInfo alloc] init];
    user.userid = joinUserInfo->user_alt_id;
    user.deviceType = joinUserInfo->device_type;
    user.userName = [NSString stringWithUTF8String:joinUserInfo->user_name];
    user.uri = [NSString stringWithUTF8String:joinUserInfo->user_alt_uri];
    logDbg(@"user:userid=%d,userName=%@,join conf",user.userid,user.userName);
    [self removeConfUserById:user.userid];
    [self.confUserArray addObject:user];
}

- (void)handleUserLeaveConfWithValue1:(TUP_UINT)value1 Value2:(TUP_ULONG)value2 data:(void *)data size:(TUP_INT)size
{
    logDbg(@"handleUserLeaveConfWithValue1:%d,Value2:%lu,size:%d",value1,value2,size);
    NSLog(@"handleUserLeaveConfWithValue1:%d,Value2:%lu,size:%d",value1,value2,size);
    TC_Conf_User_Record *leaveUserInfo = (TC_Conf_User_Record *)data;
    TUP_UINT32 leaveUserid = leaveUserInfo->user_alt_id;
    [self removeConfUserById:leaveUserid];
    NSString *userId = [NSString stringWithFormat:@"%d",leaveUserid];
    NSString *userName = [NSString stringWithFormat:@"%s",leaveUserInfo->user_name];
    NSDictionary *userInfo = @{MS_CONF_USER_LEAVE_ID_KEY:userId,MS_CONF_USER_JOIN_NAME_KEY:userName};
//    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_USER_LEAVE object:nil userInfo:userInfo];
    [[CCConfManager shareInstance] terminalConf];
}


#pragma mark ------ 根据组件id注册回调函数
/**
 *  根据组件id注册回调函数
 *
 *  @param componentID 组件id
 */
- (void)registComponentsCallBackWithComponentID:(TUP_UINT32)componentID
{
    
    if (IID_COMPONENT_BASE == (componentID & IID_COMPONENT_BASE))
    {
        TUP_RESULT dsRet = tup_conf_reg_component_callback(_confHandle, IID_COMPONENT_BASE, ComponentCallBack);
        if (dsRet != TC_OK)
        {
            logErr(@"tup_conf_reg_component_callback IID_COMPONENT_BASE failed:%d",dsRet);
        }
    }
    
    if (IID_COMPONENT_DS == (componentID & IID_COMPONENT_DS))
    {
        TUP_RESULT dsRet = tup_conf_reg_component_callback(_confHandle, IID_COMPONENT_DS, ComponentCallBack);
        if (dsRet != TC_OK)
        {
            logErr(@"tup_conf_reg_component_callback IID_COMPONENT_DS failed:%d",dsRet);
        }
    }
    if (IID_COMPONENT_VIDEO == (componentID & IID_COMPONENT_VIDEO))
    {
        TUP_RESULT videoRet = tup_conf_reg_component_callback(_confHandle, IID_COMPONENT_VIDEO, ComponentCallBack);
        if (videoRet != TC_OK)
        {
            logErr(@"tup_conf_reg_component_callback IID_COMPONENT_VIDEO failed:%d",videoRet);
        }
    }
    if (IID_COMPONENT_AS == (componentID & IID_COMPONENT_AS))
    {
        TUP_RESULT asRet = tup_conf_reg_component_callback(_confHandle, IID_COMPONENT_AS, ComponentCallBack);
        if (asRet != TC_OK)
        {
            logErr(@"tup_conf_reg_component_callback IID_COMPONENT_AS failed:%d",asRet);
        }
    }
    
}

#pragma mark --------- Component Call Back
/**
 *  组件回调函数
 *
 */
TUP_VOID ComponentCallBack(CONF_HANDLE confHandle, TUP_INT nType, TUP_UINT nValue1, TUP_ULONG nValue2, TUP_VOID* pData, TUP_INT nSize)
{
    [[CCConfManager shareInstance] handleComponentCallBackWithType:nType
                                                           Value1:nValue1
                                                           Value2:nValue2
                                                             data:pData
                                                             size:nSize];
}

- (void)handleComponentCallBackWithType:(TUP_INT)nType Value1:(TUP_UINT)value1 Value2:(TUP_ULONG)value2 data:(void *)data size:(TUP_INT)size
{
    switch (nType)
    {
            // 新建一个文档通知
        case COMPT_MSG_DS_ON_DOC_NEW:
        {
            logDbg(@"COMPT_MSG_DS_ON_DOC_NEW");
            [self confSetCurrentPage:IID_COMPONENT_DS value1:value1 value2:value2 sync:1];
            break;
        }
            // 新建一页通知
        case COMPT_MSG_DS_ON_PAGE_NEW:
        {
            logDbg(@"COMPT_MSG_DS_ON_DOC_NEW");
            [self confSetCurrentPage:IID_COMPONENT_DS value1:value1 value2:value2 sync:1];
            break;
        }
            // 同步翻页预先通知
        case COMPT_MSG_DS_ON_CURRENT_PAGE_IND:
        {
            logDbg(@"COMPT_MSG_DS_ON_CURRENT_PAGE_IND");
            [self handleConfSharedDocPageChangedWithValue:value1 value2:value2 data:data dataLength:size];
            break;
        }
            // 文档界面数据通知
        case COMPT_MSG_DS_ON_DRAW_DATA_NOTIFY:
        {
            logDbg(@"COMPT_MSG_DS_ON_DRAW_DATA_NOTIFY ");
            [self getSuraceBmpWithComponet:IID_COMPONENT_DS value1:value1 value2:value2 data:data];
            break;
        }
            // 删除一页通知
        case COMPT_MSG_DS_ON_PAGE_DEL:
        {
            logDbg(@"COMPT_MSG_DS_ON_PAGE_DEL ");
            break;
        }
            // 删除一个文档
        case COMPT_MSG_DS_ON_DOC_DEL:
        {
            logDbg(@"COMPT_MSG_DS_ON_DOC_DEL ");
            break;
        }
            
//        case COMPT_MSG_DS_ON_CURRENT_PAGE_IND:  //同步翻页预先通知
//        {
//            TUP_UINT32 VALUE2 = (TUP_UINT32)value2;
//            TUP_RESULT ret = tup_conf_ds_set_current_page(_confHandle, IID_COMPONENT_DS, value1, VALUE2, 0);
//            if (ret != TC_OK)
//            {
//                logErr(@"set_current_page failed:%d",ret);
//            }
//             break;
//
//        }
           
        case COMPT_MSG_VIDEO_ON_SWITCH:
        {
            [self handleVideoSwitchWithValue:value1 value2:value2 data:data dataLength:size];
             break;
        }
           
        case COMPT_MSG_VIDEO_ON_DEVICE_INFO:
        {
            [self handleVideoDeviceInfoWithValue:value1 value2:value2 data:data dataLength:size];
            break;
            
        }
            
        case COMPT_MSG_VIDEO_ON_NOTIFY:
        {
            break;
        }
            
        case COMPT_MSG_AS_ON_SHARING_STATE: //屏幕共享状态
        {
            [self handleScreenShareState:value1 value2:value2 data:data dataLength:size];
             break;
        }
           
        case COMPT_MSG_AS_ON_SCREEN_DATA:  //屏幕共享数据
        {
            [self handleScreenShare:value1 value2:value2 data:data dataLength:size];
             break;
        }
           
        case COMPT_MSG_DS_JSON_PAGEINFO:
        {
            
             break;
        }
           
            
        case COMPT_MSG_AS_ON_SHARING_SESSION:
        {
//            TC_SIZE dispSize = {200, 200};
//
//            TUP_RESULT retCanvas = tup_conf_ds_set_canvas_size(_confHandle, IID_COMPONENT_DS,dispSize, 1);
//            logDbg(@"retCanvas:%d",retCanvas);
             break;
        }
           
       
        case COMPT_MSG_DS_ON_CURRENT_PAGE:  //
        {
              break;
        }
          
       
    
        case COMPT_MSG_DS_JSON_DOCINFO:  //同步翻页成功
        {
            break;
        }
            
            
            
            
        case COMPT_MSG_DS_ON_DOCLOAD_FINISH:
        {
            TC_SIZE dispSize = {SCREEN_WIdTH, 200};
            
           
            TUP_RESULT retCanvas = tup_conf_ds_set_canvas_size(_confHandle, IID_COMPONENT_DS,dispSize, 1);
            logDbg(@"retCanvas:%d",retCanvas);
            break;
        }
            
            
            
//        case COMPT_MSG_DS_ON_DRAW_DATA_NOTIFY:  //文档界面数据
//        {
//            [self getSuraceBmpWithComponet:IID_COMPONENT_DS value1:value1 value2:value2 data:data];
//             break;
//        }
           
       
            
        default:
            break;
    }
}

- (void)handleConfSharedDocPageChangedWithValue:(int)nValue1 value2:(long)nValue2 data:(void*)pdata dataLength:(int)nSize
{
    // get current page size
    TUP_UINT32 pageId = nValue2;
    if (0 == nValue2)
    {
        logDbg(@"<INFO>:COMPT_MSG_DS_ON_CURRENT_PAGE_IND:DS_CHANGE");
        DsDocInfo sizeZoom;
        int errOut = tup_conf_ds_get_docinfo(_confHandle, IID_COMPONENT_DS, nValue1, &sizeZoom);
        if (TC_OK != errOut)
        {
            logDbg(@"<ERROR>conf_ds_get_docinfo error:%d",errOut);
            return;
        }
        logDbg(@"<INFO>conf_ds_get_docinfo pageId:%d",sizeZoom.currentPage);
        pageId = sizeZoom.currentPage;
    }
    DsPageInfo pageinfo;
    int err = tup_conf_ds_get_pageinfo(_confHandle, IID_COMPONENT_DS, nValue1, pageId, &pageinfo);
    logDbg(@"<inf0>: COMPT_MSG_DS_ON_CURRENT_PAGE: get page info docId=%d, pageId=%ld, pageWidth=%d, pageHieght=%d, pageScale=%d!",
              nValue1, nValue2, pageinfo.width, pageinfo.height, pageinfo.zoomPercent);
    if (TC_OK != err)
    {
        logDbg(@"<ERROR>: COMPT_MSG_DS_ON_CURRENT_PAGE: get page info fialed!");
    }
    else
    {
        TC_SIZE disp = {pageinfo.width, pageinfo.height};
        err = tup_conf_ds_set_canvas_size(_confHandle, IID_COMPONENT_DS, disp,0);
        logDbg(@"<INFO>: tup_conf_ds_set_canvas_size:%d", err);
        err = tup_conf_ds_set_current_page(_confHandle, IID_COMPONENT_DS, nValue1, nValue2, 0);
        logDbg(@"<INFO>: tup_conf_ds_set_current_page:%d", err);
    }
}

//-(BOOL)getServiceCurrentData
//{
//    DsSyncInfo info;
//    TUP_RESULT iRetService = tup_conf_ds_get_syncinfo(_confHandle,IID_COMPONENT_WB,&info);
//    logDbg(@"iRetService:%d",iRetService);
//    if (iRetService == TC_OK)
//    {
//        TUP_RESULT iRetWB = tup_conf_ds_set_current_page(_confHandle, IID_COMPONENT_WB,
//                                                         info.docId, info.pageId, 0);
//        logDbg(@"getServiceCurrentData iRetWB:%d info.docId:%d--%d",iRetWB,info.docId,info.pageId);
//        if (iRetWB != TC_OK)
//        {
//            return NO; }
//    }
//
//    return iRetService == TC_OK ? YES:NO;
//}
-(BOOL)confSetCurrentPage:(COMPONENT_IID)component value1:(int)nValue1 value2:(long)nValue2 sync:
(TUP_BOOL)sync
{
    TUP_RESULT result = tup_conf_ds_set_current_page(_confHandle, component, nValue1, nValue2,sync);
    logDbg(@"tup_conf_ds_set_current_page :%d, component is :%d",result,component);
    if (result != TC_OK)
    {
        logDbg(@"tup_conf_ds_set_current_page error:%d",result);
    }
    return result == TC_OK ? YES : NO;
}

-(void)handleVideoSwitchWithValue:(int)value1 value2:(long)value2 data:(void*)data dataLength:(int)size
{
    logDbg(@"handleVideoSwitchWithValue:%d,value2:%ld,size:%d",value1,value2,size);
    TUP_ULONG userID = value2;
    TUP_UINT32 deviceID = *((TUP_UINT32 *)data);
    TUP_UINT32 selfID = _selfUserID;
    logDbg(@"userID:%lu,selfID:%d",userID,selfID);
    if (value1 == 1)
    {
        [self storeUserInfoWithuserId:userID deviceId:deviceID];
        [self handleOpenWithUserId:userID selfId:selfID deviceId:deviceID];
    }
    else if (value1 == 0)
    {
        [self handleCloseWithUserId:userID selfId:selfID deviceId:deviceID];
    }
}

- (void)storeUserInfoWithuserId:(TUP_ULONG)userID deviceId:(TUP_INT32)deviceID
{
    BOOL isUpdate = NO;
    if (self.confUserArray.count > 0)
    {
        for (int i = 0; i < self.confUserArray.count; i++)
        {
            CCConfUserInfo *user = [self.confUserArray objectAtIndex:i];
            if (user.userid == userID)
            {
                user.deviceId = deviceID;
                [self.confUserArray replaceObjectAtIndex:i withObject:user];
                isUpdate = YES;
                break;
            }
        }
    }
    if (!isUpdate)
    {
        CCConfUserInfo *confuser = [[CCConfUserInfo alloc] init];
        confuser.userid = (TUP_UINT32)userID;
        confuser.deviceId = deviceID;
        [self.confUserArray addObject:confuser];
    }
}


- (void)handleCloseWithUserId:(TUP_ULONG)userID selfId:(TUP_INT32)selfID deviceId:(TUP_INT32)deviceID
{
    if (userID == selfID)
    {
        CCConfCameraInfo *ConfcamereInfo = nil;
        for (CCConfCameraInfo *cameraInfo in self.cameraInfoArray)
        {
            if ((cameraInfo.userID == userID) && (cameraInfo.deviceID == deviceID))
            {
                ConfcamereInfo = cameraInfo;
                break;
            }
        }
       [self detachVideoViewWithCameraInfo:ConfcamereInfo];
    }
    else
    {
        CCConfCameraInfo *remoteCameInfo = [[CCConfCameraInfo alloc] init];
        remoteCameInfo.userID = (TUP_UINT32)userID;
        remoteCameInfo.deviceID = deviceID;
        remoteCameInfo.videoView = self.remoteWindowView;
        [self detachVideoViewWithCameraInfo:remoteCameInfo];
    }
}

- (void)handleOpenWithUserId:(TUP_ULONG)userID selfId:(TUP_INT32)selfID deviceId:(TUP_INT32)deviceID
{
    if (userID == selfID)
    {
        CCConfCameraInfo *ConfcamereInfo = nil;
        for (CCConfCameraInfo *cameraInfo in self.cameraInfoArray)
        {
            if ((cameraInfo.userID == userID) && (cameraInfo.deviceID == deviceID))
            {
                ConfcamereInfo = cameraInfo;
                break;
            }
        }
        [self openLocalCamera];
        [self attachVideoViewWithCameraInfo:ConfcamereInfo];
    }
    else
    {
        CCConfCameraInfo *remoteCameInfo = [[CCConfCameraInfo alloc] init];
        remoteCameInfo.userID = (TUP_UINT32)userID;
        remoteCameInfo.deviceID = deviceID;
        remoteCameInfo.videoView = self.remoteWindowView;
        [self attachVideoViewWithCameraInfo:remoteCameInfo];
    }
}

-(void)handleVideoDeviceInfoWithValue:(int)value1 value2:(long)value2 data:(void*)data dataLength:(int)size
{
    TC_DEVICE_INFO *pDeviceInfo = (TC_DEVICE_INFO *)data;
    for (int i = 0;i < value2 ; i++)
    {
        TC_DEVICE_INFO tcDeviceInfo = pDeviceInfo[i];
        for (int j = 0; j < self.confUserArray.count; j ++)
        {
            CCConfUserInfo *user = [self.confUserArray objectAtIndex:i];
            if (tcDeviceInfo._UserID == user.userid)
            {
                if (value1)
                {
                    [self.confUserArray replaceObjectAtIndex:i withObject:user];
                    break;
                }
            }
        }
        for (int i = 0; i < value2; i ++)
        {
            TC_DEVICE_INFO tcDeviceInfo = pDeviceInfo[i];
            if(tcDeviceInfo._UserID == _selfUserID)
            {
                continue;
            }
        }
    }
}


-(void)handleScreenShareState:(int)nValue1 value2:(long)nValue2 data:(void*)pData dataLength:(int)nSize
{
    logDbg(@"handleScreenShareState:%d,value2:%ld,dataLength:%d",nValue1,nValue2,nSize);
    switch (nValue2)
    {
        case AS_STATE_NULL:
        {
            logDbg(@"screen share stop");
            if (self.screenView != nil)
            {
                [self.screenView setImage:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_SCREEN_SHARE_STOP object:nil];
        }
            break;
        case AS_STATE_START:
        {
            logDbg(@"screen share start");
        }
            break;
        default:
            break;
    }
}
-(void)getSuraceBmpWithComponet:(COMPONENT_IID)component value1:(int)nValue1 value2:(long)nValue2 data:(void*)pdata
{
    int width = 0;
    int height = 0;
    void* pData = NULL;
    pData = tup_conf_ds_get_surfacebmp(_confHandle, component, (TUP_UINT32*)&width, (TUP_UINT32*)&height);
    if (pData != NULL)
    {
        int realLen = *((int*)((char*)pData + 2));
        //NSData* data = [NSData dataWithBytesNoCopy:pData length:realLen freeWhenDone:NO];
        NSData *data = [NSData dataWithBytes:(void*)pData length:realLen];
        UIImage* image = [[UIImage alloc] initWithData:data];
        if (!image)
        {
            logDbg(@"obtain image error");
            return;
        }
        if (self.fileView != nil)
        {
            [self.fileView setImage:image];
        }
//        NSDictionary *shareDataInfo = @{
//                                        DATACONF_SHARE_DATA_KEY:image
//                                        };
//        [self respondsDataConferenceDelegateWithType:DATACONF_RECEIVE_SHARE_DATA result:shareDataInfo];
        return;
    }
    logDbg(@"pData is empty");
}
-(void)handleScreenShare:(int)nValue1 value2:(long)nValue2 data:(void*)pData dataLength:(int)nSize
{
    logDbg(@"handleScreenShare:%d,value2:%ld,dataLength:%d",nValue1,nValue2,nSize);
    TC_AS_SCREENDATA screenData;
    memset_s((void *)(&screenData), sizeof(screenData), 0, sizeof(screenData));
    TUP_RESULT dataRet = tup_conf_as_get_screendata(_confHandle, &screenData);
    if (dataRet != TC_OK)
    {
        logErr(@"tup_conf_as_get_screendata failed:%d",dataRet);
        return;
    }
    char *data = (char *)screenData.pData;
    TUP_UINT32 ssize = *((TUP_UINT32 *)((char *)data + sizeof(TUP_UINT16)));
    NSData *imageData = [NSData dataWithBytes:data length:ssize];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (image == nil)
    {
        logErr(@"share image from data fail!");
        return;
    }
    if (self.screenView != nil)
    {
        [self.screenView setImage:image];
    }
    NSDictionary *shareDataInfo = [NSDictionary dictionaryWithObject:image forKey:SCREEN_SHARE_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_SCREEN_DATA_RECEIVE object:nil userInfo:shareDataInfo];
}


- (BOOL)switchCameraWithIndex:(int)index
{
    if (_confHandle == 0)
    {
        return NO;
    }
    tup_conf_video_close(_confHandle, _selfDeviceID);
    
    CCConfCameraInfo *cameraInfo = [self.cameraInfoArray objectAtIndex:index];
    _cameraIndex = index;
    self.selfDeviceID = cameraInfo.deviceID;
    if (_isQuality)
    {
        [self setVideoMode:0];
    }
    else
    {
        [self setVideoMode:1];
    }
    TUP_RESULT cameraRes = tup_conf_video_open(_confHandle, cameraInfo.deviceID, YES);
    [self orientationChanged];
    logDbg(@"change cameraindex:%d",cameraRes);
    return (cameraRes == TC_OK);
}


- (void)openLocalCamera
{
    logDbg(@"start open local camera");
    if (!_localCameraIsOpen)
    {
        if (self.cameraInfoArray.count > 0)
        {
            CCConfCameraInfo *cameraInfo = [self.cameraInfoArray objectAtIndex:1];
            _cameraIndex = 1;
            TUP_UINT32 deviceId = cameraInfo.deviceID;
            self.selfDeviceID = cameraInfo.deviceID;
            TC_VIDEO_PARAM videoParam;
            memset_s(&videoParam, sizeof(TC_VIDEO_PARAM), 0, sizeof(TC_VIDEO_PARAM));
            videoParam.xResolution = 352;
            videoParam.yResolution = 288;
            videoParam.nFrameRate = 30;
            tup_conf_video_setparam(_confHandle, deviceId, &videoParam);
            TUP_RESULT openRet = tup_conf_video_open(_confHandle, deviceId, YES);
            [self orientationChanged];
            if (openRet != TC_OK)
            {
                logErr(@"openLocalCamera fail!");
                return;
            }
            logDbg(@"open local camera success");
            _localCameraIsOpen = YES;
        }
    }
}

- (void)removeConfUserById:(TUP_UINT32)userid
{
    if (self.confUserArray.count == 0)
    {
        return;
    }
    
    for (int i = 0; i < self.confUserArray.count; i++)
    {
        CCConfUserInfo *user = [self.confUserArray objectAtIndex:i];
        if (userid == user.userid)
        {
            [self.confUserArray removeObject:user];
        }
    }
    
}

//视频通话中锁屏必须detach视频窗口，否则可能崩溃
-(void)handleUIApplicationWillResignActiveNotification
{
    if ((0 != _localCameraInfo.deviceID) && _localAttached)
    {
        [self detachVideoViewWithCameraInfo:_localCameraInfo];
    }
    if ((0 != _remoteCameraInfo.deviceID) && _remoteAttached)
    {
        [self detachVideoViewWithCameraInfo:_remoteCameraInfo];
    }
}

//视频通话中应用激活时必须重新绑定视频窗口
- (void)handleUIApplicationDidBecomeActiveNotification
{
    if ((0 != _localCameraInfo.deviceID) && !_localAttached)
    {
        [self attachVideoViewWithCameraInfo:_localCameraInfo];
    }
    
    if ((0 != _remoteCameraInfo.deviceID) && !_remoteAttached)
    {
        [self attachVideoViewWithCameraInfo:_remoteCameraInfo];
    }
}

//记住视频窗口，解锁屏时会做绑定、解绑定动作，防止crash
- (void)updateCameraInfo:(TUP_UINT32)userid andDeviceId:(TUP_UINT32)deviceId withVideoView:(id)pWnd isAttached:(BOOL)bAttached
{
    if (userid == _selfUserID)
    {
        _localCameraInfo.userID = userid;
        _localCameraInfo.deviceID = deviceId;
        _localCameraInfo.videoView = (id)pWnd;
        _localAttached= bAttached;
    }
    else
    {
        _remoteCameraInfo.userID = userid;
        _remoteCameraInfo.deviceID = deviceId;
        _remoteCameraInfo.videoView = (id)pWnd;
        _remoteAttached = bAttached;
    }
}

- (void)attachVideoViewWithCameraInfo:(CCConfCameraInfo *)cameraInfo
{
    TUP_RESULT attachRet =  tup_conf_video_attach(_confHandle, cameraInfo.userID, cameraInfo.deviceID, (__bridge void *)cameraInfo.videoView, true, 2);
    logDbg(@"tup_conf_video_attach,userid=%d,deviceid=%d,result=%d",cameraInfo.userID,cameraInfo.deviceID,attachRet);
    if (attachRet == TC_OK)
    {
        [self updateCameraInfo:cameraInfo.userID andDeviceId:cameraInfo.deviceID withVideoView:cameraInfo.videoView isAttached:YES];
    }
}

- (void)detachVideoViewWithCameraInfo:(CCConfCameraInfo *)cameraInfo
{
    TUP_RESULT detachRet =  tup_conf_video_detach(_confHandle, cameraInfo.userID, cameraInfo.deviceID, (__bridge void *)cameraInfo.videoView, false);
    logDbg(@"tup_conf_video_detach,userid=%d,deviceid=%d,result=%d",cameraInfo.userID,cameraInfo.deviceID,detachRet);
    if (detachRet == TC_OK)
    {
        [self updateCameraInfo:cameraInfo.userID andDeviceId:cameraInfo.deviceID withVideoView:cameraInfo.videoView isAttached:NO];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
