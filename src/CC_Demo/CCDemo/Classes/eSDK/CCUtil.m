//
//  CCUtil.m
//  CCUtil
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

//#import "CCUtil.h"
#import "CCRequestClient.h"
#import "CCAccountInfo.h"
#import "CCCommonUtil.h"
#import "CCNotificationsDefine.h"
#import "CCICSService.h"
#import "CCDefineHead.h"
#import "CCCallService.h"
#import "CCConfManager.h"
#import "CCConstantInfo.h"
#import "CCLogger.h"


const int SERVER_TYPE_TP = 1;
const int SERVER_TYPE_MS = 2;

NSString *const VIDEO_CALL = @"0";
NSString *const AUDIO_CALL = @"2";

static NSString *_sdkVersion = @"2.1.10";

static CCUtil *cc_sdk = nil;

@interface CCUtil ()
{
    NSString *_entryIP;
}

@end


@implementation CCUtil

+ (CCUtil *)shareInstance
{
    @synchronized(self)
    {
        if (cc_sdk == nil)
        {
            cc_sdk = [[CCUtil alloc] init];
        }
    }
    return cc_sdk;
}

- (NSString *)getVersion
{
    logInfo(@"ICP iOS sdk version:%@",_sdkVersion);
    return _sdkVersion;
}

- (BOOL)setLogPath:(NSString *)path level:(CCLogLevel)level
{
    if (!(level == LOG_ERROR || level == LOG_WARNING || level == LOG_INFO || level == LOG_DEBUG || level == LOG_NONE))
    {
        logErr(@"log Level invalid.");
        return NO;
    }
    
    [[CCLogger defaultLogger]setLogPath:path];
    [[CCLogger defaultLogger]setLogLevel:level];
    
    [CCConstantInfo shareInstance].logLevel = level;
    
    logInfo(@"set log success.log level: %ld",(long)level);
    
    return YES;
}

- (void)initSDK
{
    logInfo(@"initSDK");
}

- (void)unInitSDK
{
    [[CCCallService shareInstance] unInitTup];
    if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_MS)
    {
        [[CCConfManager shareInstance] unInitConf];
    }
    
    logInfo(@"unInitSDK");
}

- (NSInteger)setSIPServerAddress:(NSString *)ip port:(NSString *)port
{
    NSString *ipAddress = ip;
    if ([ip length] == 0 || ip == nil)
    {
        logErr(@"sip server host is inValid");
        return RET_ERROR_PARAM;
    }

    if (![CCCommonUtil isValidPort:port])
    {
        logErr(@"sip server port is inValid");
        return RET_ERROR_PARAM;
    }
    if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
    {
        [CCCallService shareInstance].serverIp = ipAddress;
        [CCCallService shareInstance].port = port;
        [CCCallService shareInstance].isSetSc = YES;
    }
    else
    {
        [CCConfManager shareInstance].serverIp = ipAddress;
        [CCConfManager shareInstance].port = port;
    }
    logInfo(@"finish sip server setting.");
    logDbg(@"%@",[NSString stringWithFormat:@"type=%d,ip=%@,port=%@",[CCConstantInfo shareInstance].serverType,ipAddress,port]);
    
    return RET_OK;
}


- (void)setTransportSecurityUseTLS:(BOOL)enableTLS useSRTP:(BOOL)enableSRTP
{
    if (enableTLS)
    {
        [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_TLS;
        
    }
    else
    {
        [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_UDP;
    }
    
    if (enableSRTP)
    {
        [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_FORCE;
    }
    else
    {
        [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_DISABLE;
    }
     [CCCallService shareInstance].isSetSecurity = [LoginInfo sharedInstance].isTLS;
    BOOL is = [CCCallService shareInstance].isSetSecurity;
    logInfo(@"set transport security.");
    logDbg(@"%@",[NSString stringWithFormat:@"enableTLS=%d,enableSRTP=%d",enableTLS,enableSRTP]);
    
}

- (NSInteger)setHostAddress:(NSString *)ip port:(NSString *)port transSecurity:(BOOL)transSec sipServerType:(int)serverType
{
    NSString *ipAddress = ip;
    if (![CCCommonUtil isValidIP:ip])
    {
        ipAddress = [CCCommonUtil queryIpWithDomain:ip];
        
        if (![CCCommonUtil isValidIP:ipAddress])
        {
            logErr(@"setHostAddress host is inValid");
            return RET_ERROR_PARAM;
        }
    }
    if (![CCCommonUtil isValidPort:port])
    {
        logErr(@"setHostAddress port is inValid");
        return RET_ERROR_PARAM;
    }
    NSString *address;
    if (transSec)
    {
        address = [NSString stringWithFormat:@"HTTPS://%@:%@",ip,port];
    }
    else
    {
        address = [NSString stringWithFormat:@"HTTP://%@:%@",ip,port];
    }
    
    [CCAccountInfo shareInstance].serverAddr = address;
    if (serverType == SERVER_TYPE_TP || serverType == SERVER_TYPE_MS)
    {
        [[CCCallService shareInstance] initTup];
        //if (serverType == SERVER_TYPE_MS)
        //{
         //   [[CCConfManager shareInstance] initConf];
        //}
    }
    else
    {
        logErr(@"server type is error");
        return RET_ERROR_PARAM;
    }
    [CCConstantInfo shareInstance].serverType = serverType;
    _entryIP = ipAddress;
    logInfo(@"finish host address setting.");
    logDbg(@"%@",[NSString stringWithFormat:@"ip=%@,port=%@,transSecurity=%d,sipServerType=%d",ip,port,transSec,serverType]);
    return RET_OK;
}

-(BOOL)setAnonymousCard:(NSString *)anonymousCard
{
    if (anonymousCard.length>0) {
         [CCCallService shareInstance].anonymousCard = anonymousCard;
        return YES;
    }
    return NO;
}


- (void)setNeedValidate:(BOOL)needValidate needValidateDomain:(BOOL)needValidateDomain certificateData:(NSData *)certificateData
{
    [CCConstantInfo shareInstance].dataCA = certificateData;
    [CCConstantInfo shareInstance].isNeedValidateDomainName = needValidateDomain;
    [CCConstantInfo shareInstance].needValidate = needValidate;
}

#pragma mark - Login
- (NSInteger) login:(NSString *)vndid userName:(NSString *)userName
{
    if (![CCCommonUtil vndidIsValid:vndid])
    {
        logErr(@"login vndid is inValid");
        return RET_ERROR_PARAM;
    }
    if ((![CCCommonUtil isValidParam:userName]))
    {
        logErr(@"login userName is inValid");
        return RET_ERROR_PARAM;
    }
    [CCAccountInfo shareInstance].vndID = vndid;
    [CCAccountInfo shareInstance].userName = userName;
    [CCAccountInfo shareInstance].loginPath = [NSString stringWithFormat:LOGIN_RELATIVE_PATH,[CCAccountInfo shareInstance].vndID,userName];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:[CCCommonUtil localIPAddress],@"userIp",@"",@"appId", _entryIP,@"entryIp",nil];
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    logInfo(@"start login");
    [[CCICSService shareInstance] requestWithUrlstring:[CCAccountInfo shareInstance].loginPath requestBody:requestBody method:POST_METHOD isGuid:NO];
    
    logDbg(@"%@",[NSString stringWithFormat:@"vndid=%@,userName=%@",vndid,userName]);
    
    return RET_OK;
}

#pragma mark - Logout
- (void)logout
{
    logInfo(@"REQ");
    [CCAccountInfo shareInstance].logoutPath = [NSString stringWithFormat:LOGOUT_RELATIVE_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
    [[CCICSService shareInstance] requestWithUrlstring:[CCAccountInfo shareInstance].logoutPath requestBody:nil method:DELETE_METHOD isGuid:YES];
    
}

#pragma mark - WebChatCall
- (NSInteger)webChatCall:(NSString *)accessCode callData:(NSString *)callData verifyCode:(NSString *)verifyCode
{
    if (![CCCommonUtil accessCodeIsValid:accessCode])
    {
        logErr(@"webChatCall accessCode is inValid");
        return RET_ERROR_PARAM;
    }
    if (callData.length > 1024)
    {
        logErr(@"webChatCall callData is inValid");
        return RET_ERROR_PARAM;
    }
    if (verifyCode == nil || verifyCode.length>10)
    {
        logErr(@"makeCall verifyCode is inValid");
        return RET_ERROR_PARAM;
    }
    logInfo(@"START UP");
    [[CCICSService shareInstance] webChatCallWithAccessCode:accessCode callData:callData verifyCode:verifyCode];
    logDbg(@"%@",[NSString stringWithFormat:@"accessCode=%@,callData=%@",accessCode,callData]);
    return RET_OK;
}

- (void)releaseWebChatCall
{
    logInfo(@"REQ");
    [[CCICSService shareInstance] releaseWebChatCall];
}
#pragma mark - Send Message
- (NSInteger)sendMsg:(NSString *)message
{
    if ([CCAccountInfo shareInstance].chatStatus != CHAT_CONNECTED)
    {
        logErr(@"sendMsg chat not connected");
        return RET_ERROR_CHAT_NOT_CONNECTED;
    }
    if (message.length == 0 || message.length > 300 || message == nil)
    {
        logErr(@"sendMsg message is inValid");
        return RET_ERROR_PARAM;
    }
    logInfo(@"SEND");
    [[CCICSService shareInstance] sendWithMsg:message];
    logDbg(@"%@",[NSString stringWithFormat:@"message=%@",message]);
    return RET_OK;
}

#pragma mark - Set Interfaces
- (BOOL)setDataRate:(int)dataRateValue
{
    logInfo(@"SET");
    //if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
   // {
        return [[CCCallService shareInstance] setSdpWithValue:dataRateValue];
    //}
   // if (dataRateValue >= 0 && dataRateValue < 512)
    //{
    //    return [[CCConfManager shareInstance] setVideoMode:1];
   // }
   // return [[CCConfManager shareInstance] setVideoMode:0];
}

- (BOOL)setVideoMode:(int)videoMode
{
    BOOL success = NO;
    if ((videoMode == 0) || (videoMode == 1))
    {
       // if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
       // {
            success = [[CCCallService shareInstance] setTacticWithValue:videoMode];
            logInfo(@"TP result is :%d.",success);
            return success;
       // }
        //success =  [[CCConfManager shareInstance] setVideoMode:videoMode];
       // logInfo(@"MS result is :%d.",success);
       // return success;
    }
    logInfo(@"videoMode is invalid.");
    return NO;
}

- (void)setVideoContainer:(id)localView remoteView:(id)remoteView
{
    logInfo(@"serverType %d",[CCConstantInfo shareInstance].serverType);
   // if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
   // {
    NSLog(@"set video window");
        [CCCallService shareInstance].localViewWindow = localView;
        [CCCallService shareInstance].remoteViewWindow = remoteView;
//    [[CCCallService shareInstance] setVideoRotate:270];
   // }
   // else
    //{
     //   [CCConfManager shareInstance].localWindowView = localView;
       // [CCConfManager shareInstance].remoteWindowView = remoteView;
   // }
}

- (void)setDesktopShareContainer:(UIImageView *)shareView
{
    logInfo(@"SET");
    [CCConfManager shareInstance].screenView = shareView;
}
- (void)setFileShareContainer:(UIImageView *)fileImageView
{
    [CCConfManager shareInstance].fileView = fileImageView;
}

- (BOOL)switchCamera:(int)index
{
    BOOL success = NO;
    if (index == 0 || index == 1)
    {
        //if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
       // {
            success = [[CCCallService shareInstance] switchVideoOrient:index];
            logInfo(@"TP result is :%d.",success);
            return success;
      //  }
        //success = [[CCConfManager shareInstance] switchCameraWithIndex:index];
      //  logInfo(@"MS result is :%d.",success);
       // return success;
    }
    logInfo(@"camera index is invalid.");
    return NO;
}

- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate
{
    BOOL success = NO;
   // if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
   // {
        success = [[CCCallService shareInstance] setVideoRotate:rotate];
        logInfo(@"TP result is :%d.",success);
        return success;
   // }
   // success = [[CCConfManager shareInstance] setVideoRotate:rotate];
   // logInfo(@"MS result is :%d.",success);
    //return success;
}

- (BOOL)changeAudioRoute:(int)route
{
    BOOL success = [[CCCallService shareInstance] changeAudioRoute:route];
    logInfo(@"result is :%d.",success);
    return success;
}

- (BOOL)setMicMute:(BOOL)isMute
{
    BOOL success = [[CCCallService shareInstance] setMicMute:isMute];
    logInfo(@"result is :%d.",success);
    return success;
}

- (BOOL)setSpeakerMute:(BOOL)isMute
{
     BOOL success = [[CCCallService shareInstance] setSpeakerMute:isMute];
    logInfo(@"result is :%d.",success);
    return success;
}

- (NSInteger)getSpeakerVolume
{
    BOOL success = [[CCCallService shareInstance] getSpeakerVolume];
    logInfo(@"result is :%d.",success);
    return success;
}

- (BOOL)setSpeakerVolume:(int)volume
{
    if (volume < 0 || volume > 100)
    {
        logInfo(@"volume param is invalid.");
        return NO;
    }
    
     BOOL success = [[CCCallService shareInstance] setSpeakerVolume:volume];
    logInfo(@"result is :%d.",success);
    return success;
}

- (void)getVerifyCode
{
     logInfo(@"REQ");
    [[CCICSService shareInstance] getVerifyCode];
}

#pragma mark - Make Call
- (NSInteger)makeCall:(NSString *)accessCode callType:(NSString *)callType callData:(NSString *)callData verifyCode:(NSString *)verifyCode mediaAbility:(NSString *)mediaAbility
{
    if (![CCCommonUtil accessCodeIsValid:accessCode])
    {
        logErr(@"makeCall accessCode is inValid");
        return RET_ERROR_PARAM;
    }
    if (![CCCommonUtil callTypeIsValid:callType])
    {
        logErr(@"makeCall callType is inValid");
        return RET_ERROR_PARAM;
    }
    
    if (callData.length > 1024)
    {
        logErr(@"makeCall callData is inValid");
        return RET_ERROR_PARAM;
    }
    if (verifyCode == nil || verifyCode.length>10)
    {
        logErr(@"makeCall verifyCode is inValid");
        return RET_ERROR_PARAM;
    }
    [CCConstantInfo shareInstance].callType  = callType;
    [[CCICSService shareInstance] makeCallConnection:accessCode callType:callType callData:callData verifyCode:verifyCode mediaAbility:mediaAbility];
    logDbg(@"%@",[NSString stringWithFormat:@"accessCode=%@,callType=%@,callData=%@,verifyCode=%@",accessCode,callType,callData,verifyCode]);
    NSLog(@"%@",[NSString stringWithFormat:@"accessCode=%@,callType=%@,callData=%@,verifyCode=%@",accessCode,callType,callData,verifyCode]);
    return RET_OK;
}

- (Stream_INFO)getChannelInfo
{
    logInfo(@"REQ");
   // if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
   // {
        return [[CCCallService shareInstance] getStreamInfo];
   // }
  //  return [[CCConfManager shareInstance] getVideoInfo];
}


- (NSInteger)updateToVideo
{
    logInfo(@"REQ");
    [[CCICSService shareInstance] applyMeetingWithCallId:[CCICSService shareInstance].callID];
    return RET_OK;
}


- (void)getCallQueueInfo
{
    logInfo(@"REQ");
    [[CCICSService shareInstance] getQueueInfo];
}


- (void)cancelQueue
{
    logInfo(@"REQ");
    [[CCICSService shareInstance] dropCall];
}

#pragma mark - Release Call
- (void)releaseCall
{
    logInfo(@"REQ");
    if ([CCCallService shareInstance].isConnected)
    {
        [[CCCallService shareInstance] releaseCall];
    }
    
    if ([CCICSService shareInstance].isBind || [CCAccountInfo shareInstance].queueStatus == CALL_QUEUE_IS) {
         [[CCICSService shareInstance] dropCall];
    }
    
    if ([CCConfManager shareInstance].isConnected)
    {
        [[CCICSService shareInstance] stopMeeting];
        [[CCConfManager shareInstance] leaveConf];
    }
}

@end
