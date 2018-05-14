//
//  CCNotificationsDefine.h
//  CCUtil
//
//  Created by  on 16/4/6.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AUTH_MSG_ON_LOGIN ;    //登录通知 @"0"-成功 其他－失败
extern NSString *const AUTH_MSG_ON_LOGOUT;    //登出通知 @"0"-成功 其他－失败

extern NSString *const CALL_GET_VERIFY_CODE; //获取验证码
extern NSString *const CALL_MSG_ON_QUEUING;      //呼叫排队
extern NSString *const CALL_MSG_ON_CANCEL_QUEUE; //取消排队
extern NSString *const CALL_MSG_ON_QUEUE_INFO;   //获取排队信息
extern NSString *const CALL_MSG_ON_QUEUE_TIMEOUT;//排队超时
extern NSString *const CALL_MSG_ON_CONNECTED;    //呼叫成功,
extern NSString *const CALL_MSG_ON_DISCONNECTED; //呼叫结束,
extern NSString *const CALL_MSG_ON_FAIL;         //呼叫失败,

extern NSString *const CHAT_MSG_ON_SUCCESS;  //发送消息成功
extern NSString *const CHAT_MSG_ON_FAIL;     //发送消息失败
extern NSString *const CHAT_MSG_ON_RECEIVE;  //收到聊天消息

extern NSString *const CALL_MSG_ON_USER_LEAVE;   //用户离开会议

extern NSString *const JOIN_MEETING_SUCCESS;      //加入会议成功
extern NSString *const JOIN_MEETING_FAIL;       //加入会议成功


extern NSString *const CALL_MSG_ON_SCREEN_DATA_RECEIVE; //收到共享数据
extern NSString *const CALL_MSG_ON_SCREEN_SHARE_STOP;   //共享结束

extern NSString *const CALL_MSG_ON_NET_QUALITY_LEVEL;   /*网络质量,[0,5]共6个等级*/

extern NSString *const CALL_MSG_ON_MEETING_RELEASE;         //主席释放会议
/************队列信息关键字**************/

extern NSString *const POSITION_KEY;  //发送消息成功
extern NSString *const ONLINEAGENTNUM_KEY;     //发送消息失败
extern NSString *const LONGESTWAITTIME_KEY;  //收到聊天消息






