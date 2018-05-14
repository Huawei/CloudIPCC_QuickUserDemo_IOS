//
//  CCDefineHead.h
//  CCUtil
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

typedef NS_ENUM(NSInteger, METHOD_RETCODE)
{
    RET_OK = 0,                          //成功
    RET_ERROR_PARAM = -1,                //参数错误
    RET_ERROR_CHAT_NOT_CONNECTED = -2,   //文字交谈未链接
    RET_ERROR_AUDIO_NOT_CONNECTED = -3,  //语音未建立
    RET_ERROR_AGENT_NOT_FREE = -4,       //无人应答
    RET_ERROR_NET_ERROR = -5,            //网络发生错误
    RET_ERROR_CONF_CREATE = -6,          //创建会议失败
    RET_ERROR_CONF_JOIN = -7             //入会失败
};

typedef NS_ENUM(NSInteger, SUCCESS_CODE)
{
    SUCCESS_LOGIN = 0,//登录成功
    SUCCESS_LOGOUT = 0,//登出成功
};


typedef struct StreamParam
{
    float sendLossFraction;         //发送方丢包率(%)
    float sendDelay;                //发送方平均时延(ms)
    float receiveLossFraction;      //接收方丢包率(%)
    float receiveDelay;             //接收方平均时延(ms)
    char encodeSize[32];            //图像分辨率（发）
    char decodeSize[32];            //图像分辨率（收）
    int   videoWidth;               //视频分辨率-宽
    int   videoHeigth;              //视频分辨率-高
    int      frameRate;                //帧率
    int   bitRate;                    //码流
}Stream_INFO;


typedef NS_ENUM(NSInteger, VIDEO_ROTATE)
{
    ROTATE_DEFAULT = 0,//不旋转
    ROTATE_90 = 90,//逆时针旋转90°
    ROTATE_180 = 180,//逆时针旋转180°
    ROTATE_270 = 270//逆时针旋转270°
};


//日志级别
typedef NS_ENUM(NSInteger, CCLogLevel)
{
    LOG_ERROR   = 0,        //错误级别
    LOG_WARNING = 1,        //警告级别
    LOG_INFO    = 2,        //一般级别
    LOG_DEBUG   = 3,        //调试级别
    LOG_NONE    = 9         //无日志
};




