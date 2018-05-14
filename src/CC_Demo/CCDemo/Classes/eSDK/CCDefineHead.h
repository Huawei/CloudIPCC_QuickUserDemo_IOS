//
//  CCDefineHead.h
//  CCUtil
//
//  Created by  on 16/4/19.
//  Copyright © 2016年 . All rights reserved.
//

#ifndef CCDefineHead_h
#define CCDefineHead_h

#define TP_MEDIA_TYPE @"22"
#define MS_MEDIA_TYPE @"2"
#define CHAT_MEDIA_TYPE @"1"

#define LocalCameraFront (1)
#define LocalCameraBack  (0)

#define TLS_VALUE @"TLS"
/*Notification*/

#define SERVER_ADDRESS_KEY @"serverAddress"

#define USER_IP_KEY   @"userIp"
#define APP_ID_KEY    @"appId"

/*Keys*/
#define RETURN_MESSAGE_KEY @"message"
#define RESULT_KEY         @"result"
#define ERROR_KEY          @"error"
#define RET_CODE_KEY       @"retcode"
#define SUCCESS_RET_CODE   @"0"
#define RELATIVE_PATH_KEY  @"relativePath"
#define RECEIVE_DATA_KEY   @"receiveData"
#define SET_COOKIE_KEY     @"Set-Cookie"
#define SET_GUID_KEY       @"Set-GUID"
#define CLICK_TODIAL_KEY   @"clickToDial"
#define UVID_KEY           @"uvid"
#define MEDIA_TYPE_KEY     @"mediaType"
#define CALLER_KEY         @"caller"
#define ACCESS_CODE_KEY    @"accessCode"
#define CALL_DATA_KEY      @"callData"
#define SEND_MESSAGE_CALLID_KEY @"callId"
#define SEND_MESSAGE_KEY   @"content"
#define TEXT_CHAT_KEY      @"chatContent"
#define VERIFY_CODE_KEY           @"verifyCode"


#define EVENT_KEY                  @"event"
#define EVENT_TYPE_KEY             @"eventType"
#define CALL_CONNECTED_VALUE       @"WECC_WEBM_CALL_CONNECTED"
#define CALL_DISCONNECTED_VALUE    @"WECC_WEBM_CALL_DISCONNECTED"
#define CALL_FAIL_VALUE            @"WECC_WEBM_CALL_FAIL"
#define CALL_QUEUING_VALUE         @"WECC_WEBM_CALL_QUEUING"
#define CALL_QUEUE_TIMEOUT_VALUE   @"WECC_WEBM_QUEUE_TIMEOUT"
#define SEND_CHAT_DATA_SUCC_VALUE  @"WECC_CHAT_POSTDATA_SUCC"
#define SEND_CHAT_DATA_FAIL_VALUE  @"WECC_CHAT_POSTDATA_FAIL"
#define RECEIVE_CHAT_DATA_VALUE    @"WECC_CHAT_RECEIVEDATA"

#define CONTENT_KEY                @"content"
#define MEDIA_TYPE_KEY             @"mediaType"
#define VC_CONFINFO_KEY            @"vcConfInfo"
#define ACCESS_NUMBER_KEY          @"accessNumber"
#define SERVER_IP_KEY              @"serverIp"
#define PORT_KEY                   @"port"
#define PROTOCOL_KEY               @"protocolType"
#define CALLID_KEY                 @"callId"
#define SCREEN_SHARE_KEY           @"screenShare"
#define FILE_SHARE_KEY             @"fileShare"
#define MEDIA_ABLILITY_KEY         @"mediaAblitiy"

#define PREPARE_JOIN_MEETING_VALUE @"WECC_MEETING_PREPARE_JOIN"
#define MS_CONFINFO_KEY            @"confInfo"
#define MS_CONFID                  @"ConfID"
#define MS_USERID                  @"UserID"
#define MS_USERTYPE                @"UserType"
#define MS_USERNAME_KEY            @"userName"
#define MS_HOSTKEY                 @"HostKey"
#define MS_SITEID                  @"SiteID"
#define MS_SITEURL                 @"SiteUrl"
#define MS_SERVERIP                @"MSServerIP"
#define MS_NATMAP                  @"MsNatMap"
#define MS_ENCRYPT                 @"ConfPrivilege"
#define MS_CONF_USER_JOIN_ID_KEY   @"ConfUserJoinId"
#define MS_CONF_USER_JOIN_NAME_KEY @"ConfUserJoinName"
#define MS_CONF_USER_LEAVE_ID_KEY  @"ConfUserLeaveId"
#define MS_CONF_USER_LEAVE_NAME_KEY @"ConfUserLeaveName"

/************队列信息**************/

#define TOTALWAITTIME_KEY          @"totalWaitTime"          //本呼叫累计排队时长
#define CURRENTDEVICEWAITTIME_KEY  @"currentDeviceWaitTime"  //本呼叫在当前技能队列的实际等待时长

#define SKILLID_KEY                @"skillId"
#define CONFIGMAXCWAITTIME_KEY     @"configMaxcWaitTime"


/*Request Header*/
#define ACCEPT_KEY              @"Accept"
#define ACCEPT_VALUE            @"application/json"
#define ACCEPT_ENCODING_KEY     @"Accept-Encoding"
#define ACCEPT_ENCODING_VALUE   @"gzip,deflate"
#define CONTENT_TYPE_KEY        @"Content-Type"
#define CONTENT_TYPE_VALUE      @"application/json;charset=utf-8"
#define COOKIE_KEY              @"cookie"
#define GUID_KEY                @"guid"

/*Request Methods*/
#define POST_METHOD             @"POST"
#define GET_METHOD              @"GET"
#define DELETE_METHOD           @"DELETE"

/*Request Paths*/
#define LOGIN_RELATIVE_PATH     @"/icsgateway/resource/onlinewecc/%@/%@/login"                    //login
#define LOGOUT_RELATIVE_PATH    @"/icsgateway/resource/onlinewecc/%@/%@/logout"                   //logout
#define MAKE_CALL_CONNECT_PATH  @"/icsgateway/resource/realtimecall/%@/%@/docreatecall" 

//建立链接
#define SEND_MESSAGE_PATH       @"/icsgateway/resource/realtimecall/%@/%@/dosendmessage"          //发送消息
#define CHECK_MESSAGE_PATH      @"/icsgateway/resource/icsevent/%@/%@"                            //轮询消息
#define QUEUE_INFO_PATH         @"/icsgateway/resource/realtimecall/%@/%@/getcallqueue?callId=%@" //排队信息
#define QUEUE_CANCEL_PATH       @"/icsgateway/resource/realtimecall/%@/%@/docancelqueuecall?callId=%@" //取消排队
#define DROP_CALL_PATH          @"/icsgateway/resource/realtimecall/%@/%@/dodropcall?callId=%@" //释放呼叫
#define REQUEST_MEETING_PATH    @"/icsgateway/resource/meetingcall/%@/%@/requestmeeting?callId=%@"//创建会议请求
#define STOP_MEETING_PATH       @"/icsgateway/resource/meetingcall/%@/%@/stopmeeting?confId=%@" //离开会议
#define GET_VERIFYCODE_PATH       @"/icsgateway/resource/verifycode/%@/%@/verifycodeforcall" //离开会议




#endif /* CCDefineHead_h */
