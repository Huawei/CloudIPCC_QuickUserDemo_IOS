//
//  CCICSService.m
//  CCUtil
//
//  Created by on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCICSService.h"
#import "CCAccountInfo.h"
#import "CCNotificationsDefine.h"
#import "CCCallService.h"
#import "CCConfInfo.h"
#import "CCDefineHead.h"
#import "CCConfManager.h"
#import "CCConstantInfo.h"
#import "CCLogger.h"

//#import "CCUtil.h"
static CCICSService *anony_Call = nil;

@interface CCICSService()
{
    NSString *_cooKie;
    NSString *_guid;
}

@end


@implementation CCICSService

+ (CCICSService *)shareInstance
{
    @synchronized(self)
    {
        if (anony_Call == nil)
        {
            anony_Call = [[CCICSService alloc] init];
            anony_Call.isLogout = YES;
        }
    }
    return anony_Call;
}

#pragma mark - Chat Call
- (void)webChatCallWithAccessCode:(NSString *)accessCode callData:(NSString *)callData verifyCode:(NSString *)verifyCode
{
    NSDictionary *postDict = nil;
    NSString *uviStr = [CCAccountInfo shareInstance].uvid;
    NSNumber *uvidNum;
    if (uviStr.length == 0 || uviStr == nil)
    {
        uvidNum = [NSNumber numberWithInt:-1];
    }
    else
    {
        uvidNum = [NSNumber numberWithInt:[uviStr intValue]];
    }
    [CCAccountInfo shareInstance].chatCallPath = [NSString stringWithFormat:MAKE_CALL_CONNECT_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];;
    postDict = @{MEDIA_TYPE_KEY:@1,CALLER_KEY:[CCAccountInfo shareInstance].userName,ACCESS_CODE_KEY:accessCode,CALL_DATA_KEY:callData,UVID_KEY:uvidNum,VERIFY_CODE_KEY:verifyCode};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"web chat call start create chat connection verify code is %@", verifyCode);
    [self requestWithUrlstring:[CCAccountInfo shareInstance].chatCallPath requestBody:postData method:POST_METHOD isGuid:YES];
}

#pragma mark - Make Call Connection
- (void)makeCallConnection:(NSString *)accessCode callType:(NSString *)callType callData:(NSString *)callData verifyCode:(NSString *)verifyCode mediaAbility:(NSString *)mediaAbility
{
    NSDictionary *postDict = nil;
    
    if ([CCConstantInfo shareInstance].serverType == SERVER_TYPE_TP)
    {
        int uvm = -1;
        [CCAccountInfo shareInstance].tpConpath = [NSString stringWithFormat:MAKE_CALL_CONNECT_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
        postDict = @{MEDIA_TYPE_KEY:@22,CALLER_KEY:[CCAccountInfo shareInstance].userName,ACCESS_CODE_KEY:accessCode,CALL_DATA_KEY:callData,UVID_KEY:[NSNumber numberWithInt:uvm],VERIFY_CODE_KEY:verifyCode};
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
        logDbg(@"tp start create connection");
        [self requestWithUrlstring:[CCAccountInfo shareInstance].tpConpath requestBody:postData method:POST_METHOD isGuid:YES];
    }
    else
    {
        NSString *uviStr =[CCAccountInfo shareInstance].uvid;
        NSNumber *uvidNum;
        if (uviStr.length == 0 || uviStr == nil)
        {
            uvidNum = [NSNumber numberWithInt:-1];
        }
        else
        {
            int value = [uviStr intValue];
            uvidNum = [NSNumber numberWithInt:value];
        }
        NSNumber *mediaAbilityType;
        if (mediaAbility.length == 0 || mediaAbility == nil)
        {
            mediaAbilityType = [NSNumber numberWithInt:-1];
        }
        else
        {
            int value = [mediaAbility intValue];
            if (1==value)
            {
                [CCCallService shareInstance].isVediocall = YES;
            }
            mediaAbilityType = [NSNumber numberWithInt:value];
        }
        
        
        
        NSLog(@"uvid is %@ %@",uvidNum,mediaAbilityType);
        [CCAccountInfo shareInstance].msConPath = [NSString stringWithFormat:MAKE_CALL_CONNECT_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
        postDict = @{MEDIA_TYPE_KEY:@2,CALLER_KEY:[CCAccountInfo shareInstance].userName,ACCESS_CODE_KEY:accessCode,CALL_DATA_KEY:callData,UVID_KEY:uvidNum,VERIFY_CODE_KEY:verifyCode,MEDIA_ABLILITY_KEY:mediaAbilityType};
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"22%@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
        logDbg(@"22%@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
        if ([callType isEqualToString:AUDIO_CALL])
        {
            if (self.isBind)
            {
                logDbg(@"ms has bind,start audio call");
                [[CCConfManager shareInstance]callWith:[CCConfManager shareInstance].serverIp port:[CCConfManager shareInstance].port callNum:[CCAccountInfo shareInstance].clickToDial];
                return;
            }
            logDbg(@"ms audio start create connection");
            [self requestWithUrlstring:[CCAccountInfo shareInstance].msConPath requestBody:postData method:POST_METHOD isGuid:YES];
        }
        else
        {
            if (self.isBind)
            {
                logDbg(@"ms has bind,start apply conf source");
                [self applyMeetingWithCallId:self.callID];
                return;
            }
            logDbg(@"ms conf start create connection");
            [self requestWithUrlstring:[CCAccountInfo shareInstance].msConPath requestBody:postData method:POST_METHOD isGuid:YES];
            
        }
    }
}

#pragma mark - Get Queue Info
- (void)getQueueInfo
{
    NSString *url= [NSString stringWithFormat:QUEUE_INFO_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName,[CCAccountInfo shareInstance].result];
    [CCAccountInfo shareInstance].queueInfoPath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    [self requestWithUrlstring:url requestBody:nil method:GET_METHOD isGuid:YES];
}

- (void)handleQueueInfo:(NSDictionary *)dict
{
    NSDictionary *queuedict = [dict objectForKey:RESULT_KEY];
    
    NSDictionary *returnDict = [queuedict dictionaryWithValuesForKeys:@[POSITION_KEY,ONLINEAGENTNUM_KEY,LONGESTWAITTIME_KEY]];
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUE_INFO object:nil userInfo:returnDict];
}

#pragma mark - Drop Call
- (void)dropCall
{
    NSString *url = [NSString stringWithFormat:DROP_CALL_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName,[CCAccountInfo shareInstance].result];
    [CCAccountInfo shareInstance].releasePath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    [self requestWithUrlstring:url requestBody:nil method:DELETE_METHOD isGuid:YES];
}


#pragma mark - Release Web Chat call
- (void)releaseWebChatCall
{
    NSString *url = [NSString stringWithFormat:DROP_CALL_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName,[CCAccountInfo shareInstance].sendCallid];
    [CCAccountInfo shareInstance].releasePath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    [self requestWithUrlstring:url requestBody:nil method:DELETE_METHOD isGuid:YES];
}

#pragma mark - Send Message
- (void)sendWithMsg:(NSString *)message
{
    [CCAccountInfo shareInstance].sendMsgPath  = [NSString stringWithFormat:SEND_MESSAGE_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
    NSString *callid = [CCAccountInfo shareInstance].sendCallid;
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:callid,SEND_MESSAGE_CALLID_KEY,message,SEND_MESSAGE_KEY, nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    [self requestWithUrlstring:[CCAccountInfo shareInstance].sendMsgPath  requestBody:postData method:POST_METHOD isGuid:YES];
}


#pragma mark - Apply && Stop Meeting
- (void)applyMeetingWithCallId:(NSString *)callId
{
    logDbg(@"applyMeetingWithCallId:%@",callId);
    NSString *url = [NSString stringWithFormat:REQUEST_MEETING_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName,callId];
    [CCAccountInfo shareInstance].confPath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    NSString *str = [CCAccountInfo shareInstance].confPath;
    [self requestWithUrlstring:url requestBody:nil method:POST_METHOD isGuid:YES];
}

- (void)stopMeeting
{
    NSString *url = [NSString stringWithFormat:STOP_MEETING_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName,[CCAccountInfo shareInstance].stopConfId];
    [CCAccountInfo shareInstance].stopConfPath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    [self requestWithUrlstring:url requestBody:nil method:POST_METHOD isGuid:YES];
}

-(void)getVerifyCode
{
    NSString *url = [NSString stringWithFormat:GET_VERIFYCODE_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
    [CCAccountInfo shareInstance].verifyCodePath = [[url componentsSeparatedByString:@"?"] objectAtIndex:0];
    [self requestWithUrlstring:url requestBody:nil method:GET_METHOD isGuid:YES];
    
}

#pragma mark - Request Delegate Meths
- (void)handleResponseData:(NSDictionary *)returnDict
{
    NSString *relativePath = [returnDict objectForKey:RELATIVE_PATH_KEY];
    NSData *receiveData = [returnDict objectForKey:RECEIVE_DATA_KEY];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([TimeUtil shareInstance].timer) {
            [[TimeUtil shareInstance] stopTimer];
        }
    });
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableContainers error:nil];
    NSString *returnCodeStr = [NSString stringWithFormat:@"%@",[dict objectForKey:RET_CODE_KEY]];
    if ([[dict objectForKey:RET_CODE_KEY] isEqualToString:SUCCESS_RET_CODE])
    {
        NSString *resultStr = [NSString stringWithFormat:@"%@",[dict objectForKey:RESULT_KEY]];
        if ([[CCAccountInfo shareInstance].tpConpath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].msConPath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].chatCallPath isEqualToString:relativePath])
        {
            logDbg(@"connection success,wait call info");
            [CCAccountInfo shareInstance].result = resultStr;
        }
        else if ([[CCAccountInfo shareInstance].eventPath isEqualToString:relativePath])
        {
            [self handleRecMsg:dict];
        }
        else if ([[CCAccountInfo shareInstance].queueInfoPath hasPrefix:relativePath])
        {
            [self handleQueueInfo:dict];
        }else if ([[CCAccountInfo shareInstance].loginPath isEqualToString:relativePath])
        {
            logDbg(@"login success");
            [CCICSService shareInstance].isLogout = NO;
            [[CCICSService shareInstance] getEvent];
            [CCAccountInfo shareInstance].cookie = _cooKie;
            [CCAccountInfo shareInstance].guid = _guid;
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGIN object:[NSString stringWithFormat:@"%ld",(long)SUCCESS_LOGIN]];
            
        }
        else if([[CCAccountInfo shareInstance].logoutPath isEqualToString:relativePath])
        {
            [CCICSService shareInstance].isLogout = YES;
            [CCICSService shareInstance].isBind = NO;
            logDbg(@"logout success");
            [CCAccountInfo shareInstance].uvid = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGOUT object:[NSString stringWithFormat:@"%ld",(long)SUCCESS_LOGOUT]];
        }
        else if([[CCAccountInfo shareInstance].verifyCodePath isEqualToString:relativePath])
        {
            NSString *bitmap =[NSString stringWithFormat:@"%@",[dict objectForKey:RESULT_KEY]];
            logDbg(@"verifyCodePath success");
            
            NSDictionary * verifyCode = [[NSDictionary alloc] initWithObjectsAndKeys:bitmap,@"verifyCode", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_GET_VERIFY_CODE object:[NSString stringWithFormat:@"%ld",(long)RET_OK] userInfo:verifyCode];
            
        }
    }
    else
    {
        if ([[CCAccountInfo shareInstance].tpConpath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].msConPath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].chatCallPath isEqualToString:relativePath])
        {
            logErr(@"create connection failed:%@",returnCodeStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:returnCodeStr];
        }
        else if ([[CCAccountInfo shareInstance].sendMsgPath isEqualToString:relativePath])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_FAIL object:returnCodeStr];
        }
        else if ([[CCAccountInfo shareInstance].queueInfoPath isEqualToString:relativePath])
        {
            logDbg(@"CALL_MSG_ON_QUEUE_INFO is not queue state returnCodeStr = %@",returnCodeStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUE_INFO object:nil userInfo:nil];
            [CCAccountInfo shareInstance].queueStatus = CALL_QUEUE_NOT;
        }else if ([[CCAccountInfo shareInstance].loginPath isEqualToString:relativePath])
        {
            logErr(@"login failed:%@",returnCodeStr);
            [CCICSService shareInstance].isLogout = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGIN object:returnCodeStr];
        }
        else if([[CCAccountInfo shareInstance].logoutPath isEqualToString:relativePath])
        {
            logErr(@"handleResponseData logout failed:%@",returnCodeStr);
            if (![returnCodeStr isEqualToString:@"-5"]) {
                [CCICSService shareInstance].isLogout = YES;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGOUT object:returnCodeStr];
        } else if([[CCAccountInfo shareInstance].verifyCodePath isEqualToString:relativePath])
        {
            
            logErr(@"get verify code failed:%@",returnCodeStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_GET_VERIFY_CODE object:[NSString stringWithFormat:@"%ld",(long)returnCodeStr]];
            
        }
        
    }
}

- (void)handleResponseError:(NSDictionary *)errorDict
{
    NSString *errStr = [NSString stringWithFormat:@"%ld",(long)RET_ERROR_NET_ERROR];
    NSString *relativePath = [errorDict objectForKey:RELATIVE_PATH_KEY];
    if ([CCICSService shareInstance].isLogout) {
        
    }else{
        if ([errStr isEqualToString:@"-5"]) {
            //        [CCICSService shareInstance].isLogout = YES;
            //        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkerror" object:errStr];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([TimeUtil shareInstance].timer) {
                    
                }else{
                    [[TimeUtil shareInstance] startTimer];
                }
            });
        }else{
            
            
        }
    }
  
    
    if ([[CCAccountInfo shareInstance].eventPath isEqualToString:relativePath] &&![CCICSService shareInstance].isLogout)
    {
        [self creatEventTimer];
        return;
    }
    
    if ([[CCAccountInfo shareInstance].tpConpath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].chatCallPath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].msConPath isEqualToString:relativePath])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:errStr];
        return;
    }
    
    if ([[CCAccountInfo shareInstance].sendMsgPath isEqualToString:relativePath])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_FAIL object:errStr];
        return;
    }
    
    if ([[CCAccountInfo shareInstance].queueInfoPath isEqualToString:relativePath])
    {
        NSLog(@"CALL_MSG_ON_QUEUE_INFO errStr %@",errStr);
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUE_INFO object:errStr];
        return;
    }
    
    if ([[CCAccountInfo shareInstance].loginPath isEqualToString:relativePath])
    {
        [CCICSService shareInstance].isLogout = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGIN object:errStr];
        return;
    }
    
    if ([[CCAccountInfo shareInstance].logoutPath isEqualToString:relativePath])
    {
        logErr(@"handleResponseError logout failed:%@",errStr);
        [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGOUT object:errStr];
        return;
    }
    
    if([[CCAccountInfo shareInstance].verifyCodePath isEqualToString:relativePath])
    {
        logErr(@"get verify code failed:");
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_GET_VERIFY_CODE object:[NSString stringWithFormat:@"%ld",(long)errStr]];
        return;
    }
}

- (void)handleResponseHeader:(NSHTTPURLResponse *)httpResponse
{
    NSString *relativePath = httpResponse.URL.relativePath;
    NSString *statusStr = [NSString stringWithFormat:@"%ld",(long)httpResponse.statusCode];
    
    if ([[CCAccountInfo shareInstance].eventPath isEqualToString:relativePath] &&![CCICSService shareInstance].isLogout)
    {
        [self creatEventTimer];
        return;
        
    }
    
    if (httpResponse.statusCode == 200)
    {
        if ([[CCAccountInfo shareInstance].loginPath isEqualToString:relativePath])
        {
            NSDictionary *headFieldDict = [httpResponse allHeaderFields];
            
            NSLog(@"tttttt head fields = %@",[headFieldDict description]);
            NSHTTPCookieStorage *cookiejar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSString *new_cookie=@"";
            for(NSHTTPCookie *cookie in [cookiejar cookies])
            {
                NSLog(@"tttttt cookie is %@",cookie);
                
                new_cookie=[new_cookie stringByAppendingFormat:@"%@=%@; Path=%@; ",[cookie name],[cookie value],[cookie path]];
                NSLog(@"cookie lllllllllllllll:%@=%@;Path=%@", [cookie name],[cookie value],[cookie path]);
                
                if([cookie isSecure])
                {
                    new_cookie=[new_cookie stringByAppendingFormat:@"Secure; "];
                }
                if([cookie isHTTPOnly])
                {
                    new_cookie=[new_cookie stringByAppendingFormat:@"HttpOnly; "];
                }
                
                
            }
            _cooKie = new_cookie;//[[headFieldDict objectForKey:SET_COOKIE_KEY] substringFromIndex:11];
            _guid = [[headFieldDict objectForKey:SET_GUID_KEY] substringFromIndex:11];
            NSLog(@"_cookie is %@",_cooKie);
            //NSLog(@"new_cookie is %@",new_cookie);
        }
        
    }
    else
    {
        if ([[CCAccountInfo shareInstance].tpConpath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].msConPath isEqualToString:relativePath] || [[CCAccountInfo shareInstance].chatCallPath isEqualToString:relativePath])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:statusStr];
        }
        else if ([[CCAccountInfo shareInstance].sendMsgPath isEqualToString:relativePath])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_FAIL object:statusStr];
        }
        else if ([[CCAccountInfo shareInstance].queueInfoPath isEqualToString:relativePath])
        {
            NSLog(@"CALL_MSG_ON_QUEUE_INFO statusStr =%@",statusStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUE_INFO object:statusStr];
        }else  if ([[CCAccountInfo shareInstance].loginPath isEqualToString:relativePath])
        {
            [CCICSService shareInstance].isLogout = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGIN object:statusStr];
        }
        else if ([[CCAccountInfo shareInstance].logoutPath isEqualToString:relativePath])
        {
            if (![statusStr isEqualToString:@"-5"])
            {
                [CCICSService shareInstance].isLogout = YES;
            }
            logErr(@"handleResponseHeader logout failed:%@",statusStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTH_MSG_ON_LOGOUT object:statusStr];
        }
    }
}


#pragma mark - Handle Event
- (void)handleRecMsg:(NSDictionary *)dict
{
    NSDictionary *eventDict = [dict objectForKey:EVENT_KEY];
    NSString *eventType = [eventDict objectForKey:EVENT_TYPE_KEY];
    
    if ([eventType isEqualToString:CALL_CONNECTED_VALUE])
    {
        NSDictionary *contentDict = [eventDict objectForKey:CONTENT_KEY];
        NSString *mediaType = [[contentDict objectForKey:MEDIA_TYPE_KEY] stringValue];
        if ([mediaType isEqualToString:TP_MEDIA_TYPE])
        {
            NSDictionary *confInfoDict = [contentDict objectForKey:VC_CONFINFO_KEY];
            [CCCallService shareInstance].accessNumber = [NSString stringWithFormat:@"%@", [confInfoDict objectForKey:ACCESS_NUMBER_KEY]];
            [CCCallService shareInstance].confCallId = [confInfoDict objectForKey:CALLID_KEY];
            
            if (![CCCallService shareInstance].isSetSc)
            {
                [CCCallService shareInstance].serverIp = [confInfoDict objectForKey:SERVER_IP_KEY];
                [CCCallService shareInstance].port = [[confInfoDict objectForKey:PORT_KEY] stringValue];
            }
            
            if (![CCCallService shareInstance].isSetSecurity)
            {
                if ([[confInfoDict objectForKey:PROTOCOL_KEY] isEqualToString:TLS_VALUE])
                {
                    [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_TLS;
                    [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_FORCE;
                }
                else
                {
                    [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_UDP;
                    [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_DISABLE;
                }
            }
            
            logDbg(@"tp receive call info,start anonymous call");
            [[CCCallService shareInstance] startAnonymousCallWithAccessNumber:[CCCallService shareInstance].accessNumber andIp:[CCCallService shareInstance].serverIp andPort:[CCCallService shareInstance].port];
        }
        else if ([mediaType isEqualToString:CHAT_MEDIA_TYPE])
        {
            logDbg(@"web chat call success,call info:%@",contentDict);
            [CCAccountInfo shareInstance].sendCallid = [CCAccountInfo shareInstance].result;
            [CCAccountInfo shareInstance].chatStatus = CHAT_CONNECTED;
            [CCAccountInfo shareInstance].uvid = [[contentDict objectForKey:UVID_KEY] stringValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_CONNECTED object:nil];
        }
        else if ([mediaType isEqualToString:MS_MEDIA_TYPE])
        {
            logDbg(@"ms call info:%@",contentDict);
            NSLog(@"ms call info: %@",contentDict);
            [CCAccountInfo shareInstance].uvid = [[contentDict objectForKey:UVID_KEY] stringValue];
            [CCAccountInfo shareInstance].clickToDial = [NSString stringWithFormat:@"%@",[contentDict objectForKey:CLICK_TODIAL_KEY]];
            [CCICSService shareInstance].callID = [NSString stringWithFormat:@"%@",[contentDict objectForKey:CALLID_KEY]];
            self.isBind = YES;
            if ([[CCConstantInfo shareInstance].callType isEqualToString:AUDIO_CALL])
            {
                NSLog(@"ms receive call data,start audio call");
//                modify by lll
                 NSDictionary *confInfoDict = [contentDict objectForKey:VC_CONFINFO_KEY];
                BOOL is =[CCCallService shareInstance].isSetSecurity;
//                 if (![CCCallService shareInstance].isSetSecurity)
//                 {
//                 if ([[confInfoDict objectForKey:PROTOCOL_KEY] isEqualToString:TLS_VALUE])
//                 {
//                 [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_TLS;
//                 [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_FORCE;
//                 }
//                 else
//                 {
//                 [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_UDP;
//                 [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_DISABLE;
//                 }
//                 }
////                 */
//                [CCCallService shareInstance].transPortModel = CALL_E_TRANSPORTMODE_UDP;
//                [CCCallService shareInstance].srtpModel = CALL_E_SRTP_MODE_DISABLE;
                
                //                 */
               
                logDbg(@"ms receive call data,start audio call");
                NSLog(@"serverip:%@ port:%@ callnum:%@",[CCConfManager shareInstance].serverIp,[CCConfManager shareInstance].port,[CCAccountInfo shareInstance].clickToDial);
                [[CCConfManager shareInstance]callWith:[CCConfManager shareInstance].serverIp port:[CCConfManager shareInstance].port callNum:[CCAccountInfo shareInstance].clickToDial];
                
                
            }
            else
            {
                logDbg(@"ms is bind,start apply conf source");
                [self applyMeetingWithCallId:[CCICSService shareInstance].callID];
            }
        }
    }
    else if ([eventType isEqualToString:CALL_FAIL_VALUE])
    {
        NSString *msg = [NSString stringWithFormat:@"%ld",(long)RET_ERROR_AGENT_NOT_FREE];
        if ([CCAccountInfo shareInstance].queueStatus == CALL_QUEUE_IS)
        {
            logDbg(@"queue is canceled");
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_CANCEL_QUEUE object:nil];
            [CCAccountInfo shareInstance].queueStatus = CALL_QUEUE_NOT;
        }
        else
        {
            logErr(@"WECC_WEBM_CALL_FAIL");
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_FAIL object:msg];
        }
    }
    else if ([eventType isEqualToString:CALL_QUEUING_VALUE])
    {
        logDbg(@"is queuing");
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUING object:nil];
        [CCAccountInfo shareInstance].queueStatus = CALL_QUEUE_IS;
    }
    else if ([eventType isEqualToString:CALL_QUEUE_TIMEOUT_VALUE])
    {
        logDbg(@"queue time out");
        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_QUEUE_TIMEOUT object:nil];
        [CCAccountInfo shareInstance].queueStatus = CALL_QUEUE_NOT;
    }
    else if ([eventType isEqualToString:SEND_CHAT_DATA_SUCC_VALUE])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_SUCCESS object:nil];
    }
    else if ([eventType isEqualToString:SEND_CHAT_DATA_FAIL_VALUE])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_FAIL object:nil];
    }
    else if ([eventType isEqualToString:RECEIVE_CHAT_DATA_VALUE])
    {
        NSDictionary *contentDict = [eventDict objectForKey:CONTENT_KEY];
        NSString *chatData = [contentDict objectForKey:TEXT_CHAT_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_MSG_ON_RECEIVE object:chatData userInfo:nil];
    }
    else if ([eventType isEqualToString:CALL_DISCONNECTED_VALUE])
    {
        NSDictionary *contentDict = [eventDict objectForKey:CONTENT_KEY];
        if ([[[contentDict objectForKey:MEDIA_TYPE_KEY] stringValue] isEqualToString:CHAT_MEDIA_TYPE])
        {
            logDbg(@"web chat call end");
            if ((![CCCallService shareInstance].isConnected) && (![CCConfManager shareInstance].isConnected))
            {
                [CCAccountInfo shareInstance].uvid = @"";
            }
            [CCAccountInfo shareInstance].chatStatus = CHAT_NOT_CONNECTED;
            [CCAccountInfo shareInstance].sendCallid = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:CALL_MSG_ON_DISCONNECTED object:nil];
        }
        else
        {
            if (self.isBind)
            {
                self.isBind = NO;
            }
            
            if ([[[contentDict objectForKey:MEDIA_TYPE_KEY] stringValue] isEqualToString:TP_MEDIA_TYPE] && [CCCallService shareInstance].isConnected) {
                
                BOOL ret =  [[CCCallService shareInstance] releaseCall];
                NSLog(@"ret = %d",ret);
            }
            
        }
    }
    else if ([eventType isEqualToString:PREPARE_JOIN_MEETING_VALUE])
    {
        CCConfInfo *confinfo = [[CCConfInfo alloc] init];
        confinfo.userName = [eventDict objectForKey:MS_USERNAME_KEY];
        confinfo.confTitle = @"";
        confinfo.logUri = @"";
        NSDictionary *contentDict = [eventDict objectForKey:CONTENT_KEY];
        logDbg(@"receive ms conf info:%@",contentDict);
        NSString *confinfoStr = [contentDict objectForKey:MS_CONFINFO_KEY];
        NSArray *confinfoArr = [confinfoStr componentsSeparatedByString:@"|"];
        for (int i = 0; i < confinfoArr.count; i++)
        {
            
            NSString *str = confinfoArr[i];
            if ([str hasPrefix:MS_CONFID])
            {
                confinfo.confId = [[[str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                [CCAccountInfo shareInstance].stopConfId = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            else if ([str hasPrefix:MS_USERID])
            {
                confinfo.userId = [[[str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                [CCConfManager shareInstance].selfUserID = confinfo.userId;
            }
            else if ([str hasPrefix:MS_USERTYPE])
            {
                confinfo.userType = 8;
            }
            else if ([str hasPrefix:MS_HOSTKEY])
            {
                confinfo.hostKey = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            else if ([str hasPrefix:MS_SITEID])
            {
                confinfo.siteId = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            else if ([str hasPrefix:MS_SITEURL])
            {
                confinfo.siteUrl = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
            }
            else if ([str hasPrefix:MS_NATMAP])
            {
                NSString *natMap = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
                if (natMap.length != 0)
                {
                    [CCConfManager shareInstance].isNat = YES;
                    [CCConfManager shareInstance].msServerIp = natMap;
                    confinfo.msServerIp = [CCConfManager shareInstance].msServerIp;
                    [CCConfManager shareInstance].outerIp = natMap;
                }
                else
                {
                    [CCConfManager shareInstance].isNat = NO;
                }
            }
            else if ([str hasPrefix:MS_SERVERIP])
            {
                NSString *serverIp = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
                [CCConfManager shareInstance].msServerIp = serverIp;
                confinfo.msServerIp = [CCConfManager shareInstance].msServerIp;
                NSString *innerStr = [[serverIp componentsSeparatedByString:@":"] objectAtIndex:0];
                [CCConfManager shareInstance].innerIp = innerStr;
            }
            else if ([str hasPrefix:MS_ENCRYPT])
            {
                confinfo.encryptKey = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
            }
        }
        logDbg(@"start create conf");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL confRet = [[CCConfManager shareInstance] createConfWithInfo:confinfo];
            if (!confRet)
            {
                [[CCICSService shareInstance] stopMeeting];
                NSString *createFail = [NSString stringWithFormat:@"%ld",(long)RET_ERROR_CONF_CREATE];
                [[NSNotificationCenter defaultCenter] postNotificationName:JOIN_MEETING_FAIL object:createFail];
            }
            else
            {
                logDbg(@"create conf success,start join conf");
                [[CCConfManager shareInstance] joinConf];
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:JOIN_MEETING_SUCCESS object:nil];
            }
            
        });
    }
}


#pragma mark - Request
- (void)requestWithUrlstring:(NSString *)url requestBody:(NSData *)body method:(NSString *)method isGuid:(BOOL)isGuid
{
    NSString *requestStr = [[CCAccountInfo shareInstance].serverAddr stringByAppendingString:url];
    CCRequestClient *requestClient = [[CCRequestClient alloc] initWithURL:requestStr];
    requestClient.request = [CCCommonUtil createURLRequestWithURLString:requestStr andRequestBody:body method:method isGuid:isGuid];
    requestClient.delegate = self;
    [requestClient startRequest];
}


#pragma mark - Get Event
- (void)getEvent
{
    [CCAccountInfo shareInstance].eventPath = [NSString stringWithFormat:CHECK_MESSAGE_PATH,[CCAccountInfo shareInstance].vndID,[CCAccountInfo shareInstance].userName];
    [self requestWithUrlstring:[CCAccountInfo shareInstance].eventPath requestBody:nil method:GET_METHOD isGuid:YES];
}

- (void)creatEventTimer{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (1.5 * NSEC_PER_SEC));
    dispatch_after(time, queue, ^{
        [self getEvent];
    });
    
}

@end

