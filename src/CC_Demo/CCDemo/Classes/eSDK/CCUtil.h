//
//  CCUtil.h
//  CCUtil
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCLogger.h"
#import "CCUtil.h"

/**
 *  TP
 */
extern const int SERVER_TYPE_TP;

/**
 *  MS
 */
extern const int SERVER_TYPE_MS;

/**
 *  VIDEO CALL
 */
extern NSString *const VIDEO_CALL;

/**
 *  AUDIO CALL
 */
extern NSString *const AUDIO_CALL;


@interface CCUtil : NSObject

/**
 *  单例
 *
 *  @return CCUtil单例
 */
+ (CCUtil *)shareInstance;

/**
 *  获取SDK版本信息
 *
 *  @return 版本信息
 */
- (NSString *)getVersion;

/**
 *  设置日志路径和级别
 *
 *  @param path  日志路径
 *  @param level 日志级别
 */
- (BOOL)setLogPath:(NSString *)path level:(CCLogLevel)level;

/**
 *  初始化SDK
 *
 */
- (void)initSDK;

/**
 *  去初始化SDK
 */
- (void)unInitSDK;

/**
 *  设置接入网关地址
 *
 *  @param ip         ip
 *  @param port        端口号
 *  @param transSec   YES-HTTPS,NO-HTTP
 *  @param serverType SERVER_TYPE_TP,SERVER_TYPE_MS
 *
 *  @return 0表示成功,其它表示参数错误
 */
- (NSInteger)setHostAddress:(NSString *)ip port:(NSString *)port transSecurity:(BOOL)transSec sipServerType:(int)serverType;

/**
 *  设置匿名卡号
 *
 *  @param anonymousCard  匿名卡号
 *
 *  @return YES表示成功,NO 表示参数错误
 */

-(BOOL)setAnonymousCard:(NSString *)anonymousCard;

/**
 *  Https证书校验
 *
 *  @param needValidate 是否需要验证证书
 *  @param needValidateDomain 是否需要域名验证
 *  @param certificateData 服务器证书
 *
 */
- (void)setNeedValidate:(BOOL)needValidate needValidateDomain:(BOOL)needValidateDomain certificateData:(NSData *)certificateData;

/**
 *  设置SIP服务器地址
 *
 *  @param ip   ip
 *  @param port 端口
 *
 *  @return 0表示成功,其它表示参数错误
 */
- (NSInteger)setSIPServerAddress:(NSString *)ip port:(NSString *)port ;

/**
 *  设置数据加密模式(TLS,SRTP)
 *
 *  @param enableTLS  YES-TLS加密，NO不加密
 *  @param enableSRTP YES-SRTP加密，NO不加密
 */
- (void)setTransportSecurityUseTLS:(BOOL)enableTLS useSRTP:(BOOL)enableSRTP;

/**
 *  登陆             异步接口, 监听AUTH_MSG_ON_LOGIN
 *
 *  @param vndid    虚拟呼叫中心id，1-999，默认为1
 *  @param userName 用户名 1-20位数字、字母或其组合
 *
 *  @return 0表示接口调用成功,其他参考返回码定义
 */
- (NSInteger)login:(NSString *)vndid userName:(NSString *)userName;

/**
 *  登出             异步接口，监听AUTH_MSG_ON_LOGOUT
 *
 */
- (void)logout;

/**
 *  发起文字交谈        异步接口,监听CALL_MSG_ON_CONNECTED
 *
 *  @param accessCode 接入码,平台配置好的数据,1-24位
 *  @param callData   呼叫随路数据,长度范围[0,1024]
 *
 *  @return 0表示接口调用成功,其他参考返回码定义
 */
- (NSInteger)webChatCall:(NSString *)accessCode callData:(NSString *)callData verifyCode:(NSString *)verifyCode;

/**
 *  发送文字消息     异步接口,监听 CHAT_MSG_ON_SUCCESS
 *                             CHAT_MSG_ON_FAIL
 *                             CHAT_MSG_ON_RECEIVE
 *
 *  @param message 消息内容，最小为1个字符，最大为300
 *
 *  @return 0表示接口调用成功,其他参考返回码定义
 */
- (NSInteger)sendMsg:(NSString *)message;

/**
 *  释放文字呼叫
 */
- (void)releaseWebChatCall;

/**
 *  发起语音／视频呼叫   异步接口,监听CALL_MSG_ON_CONNECTED
 *
 *  @param accessCode 接入码,平台配置好的数据,1-24位
 *  @param callType   呼叫类型,AUDIO_CALL,VIDEO_CALL
 *  @param callData   呼叫随路数据,长度范围[0,1024]
 *
 *  @return 0表示接口调用成功,其他参考返回码定义
 */

- (NSInteger)makeCall:(NSString *)accessCode callType:(NSString *)callType callData:(NSString *)callData verifyCode:(NSString *)verifyCode mediaAbility:(NSString *)mediaAbility;
- (NSInteger)makeCall:(NSString *)accessCode callType:(NSString *)callType callData:(NSString *)callData verifyCode:(NSString *) mediaAbility:(NSString *)mediaAbility;

/**
 *  升级语音呼叫到视频呼叫     异步接口,监听CALL_MSG_ON_CONNECTED
 *
 *  @return 0表示接口调用成功,其他参考返回码定义
 */
- (NSInteger)updateToVideo;

/**
 *  结束呼叫
 *
 */
- (void)releaseCall;

/**
 *  获取排队信息        异步接口,监听CALL_MSG_ON_QUEUE_INFO
 *  排队信自字典，对应如下：
 *  Key                    |    Value      |  note
 *———————————————————————————————————————————————————————————————————————
 *  position               |    NSString   | 本呼叫在队伍中的位置
 *  totalWaitTime          |    NSString   | 本呼叫累计排队时长
 *  currentDeviceWaitTime  |    NSString   | 本呼叫在当前技能队列的实际等待时长
 *————————————————————————————————————————————————————————————————————————
 *
 */
- (void)getCallQueueInfo;

/**
 *  取消排队  异步接口,监听CALL_MSG_ON_CANCEL_QUEUE
 *
 */
- (void)cancelQueue;

/**
 *  设置本地和远端视频显示容器
 *
 *  @param localView  本地view
 *  @param remoteView 远端view
 *
 */
- (void)setVideoContainer:(id)localView remoteView:(id)remoteView;

/**
 *  设置桌面共享显示容器
 *
 *  @param shareView 桌面共享View
 */
- (void)setDesktopShareContainer:(UIImageView *)shareView;

/**
 *  设置file
 *
 *  @param shareView file
 */
- (void)setFileShareContainer:(UIImageView *)fileImageView;
/**
 *  获取视频流信息 struct StreamParam
 *
 *  @return struct Stream_INFO
 */
- (Stream_INFO)getChannelInfo;

/**
 *  设置视频显示模式
 *
 *  @param videoMode 0-图像质量优先，1-流畅优先
 *
 *  @return YES表示成功，NO失败

 */
- (BOOL)setVideoMode:(int)videoMode;

/**
 *  设置带宽
 *
 *  @param dataRateValue 支持128K,256K,384K,512K,768K
 *
 *  @return YES表示成功，NO失败
 */
- (BOOL)setDataRate:(int)dataRateValue;

/**
 *  切换前置／后置摄像头
 *
 *  @param index 1-前置,0-后置
 *
 *  @return YES表示成功，NO表示失败
 */
- (BOOL)switchCamera:(int)index;

/**
 *  设置视频旋转角度
 *
 *  @param rotate 旋转角度的枚举值
 *
 *  @return 是否旋转成功
 */
- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate;

/**
 *  获取扬声器音量
 *
 *  @return 音量大小
 */
- (NSInteger)getSpeakerVolume;

/**
 *  设置扬声器音量
 *
 *  @param volume 音量大小,[0,100]
 *
 *  @return YES表示成功，NO表示失败
 */
- (BOOL)setSpeakerVolume:(int)volume;

/**
 *   切换扬声器／听筒
 *
 *  @param route 0-听筒，1-扬声器
 *
 *  @return YES表示成功，NO表示失败
 */
- (BOOL)changeAudioRoute:(int)route;

/**
 *  扬声器静音
 *
 *  @param isMute YES-静音，NO-取消静音
 *
 *  @return YES表示成功，NO表示失败
 */
- (BOOL)setSpeakerMute:(BOOL)isMute;

/**
 *  静音／取消静音（麦克风）
 *
 *  @param isMute YES-静音，NO-取消静音
 *
 *  @return YES表示成功，NO表示失败
 */
- (BOOL)setMicMute:(BOOL)isMute;

/**
 *  获取验证码
 *
 */
- (void)getVerifyCode;
@end
