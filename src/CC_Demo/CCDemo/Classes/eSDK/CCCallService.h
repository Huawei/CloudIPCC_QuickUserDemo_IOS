//
//  CCallServer.h
//  CCUtil
//
//  Created by on 16/4/12.
//  Copyright © 2016年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CCCommonUtil.h"
#import "CCICSService.h"
#import "CCConfManager.h"


#import "call_interface.h"
#import "call_advanced_interface.h"
#import "call_def.h"

//视频操作类型枚举
typedef enum
{
    OPEN = 0x01,             //开启摄像头
    CLOSE = 0x02,            //关闭摄像头
    START = 0x04,           //开始视频
    OPEN_AND_START = 0x05,   //同时执行开始并打开摄像头操作
    STOP = 0x08             //停止视频
}EN_VIDEO_OPERATION;

//视频操作模块枚举
typedef enum
{
    REMOTE = 0x01,                  //对远端画面操作
    LOCAL = 0x02,                   //对本端画面操作
    LOCAL_AND_REMOTE = 0x03,        //同时对本远端画面操作
    CAPTURE = 0x04,                 //对摄像头操作
    ENCODER = 0x08,                 //编码
    DECODER = 0x10,                 //解码
    RESTARTCAPTUREANDENCODER = 0x0C //重启摄像头和编码
}EN_VIDEO_OPERATION_MODULE;

//视频操作模块枚举
typedef enum
{
    DATARATEVALUE_128 = 128,
    DATARATEVALUE_256 = 256,
    DATARATEVALUE_384 = 384,
    DATARATEVALUE_512 = 512,
    DATARATEVALUE_768 = 768
};



@interface CCCallService : NSObject

@property (nonatomic, copy) NSString *accessNumber;
@property (nonatomic, assign) BOOL isSetSc;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isSetSecurity;
@property (nonatomic, assign) BOOL isVediocall;

@property (nonatomic, copy) NSString *callType;
@property (nonatomic, copy) NSString *serverIp;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *confCallId;
@property (nonatomic, assign) id localViewWindow;
@property (nonatomic, assign) id remoteViewWindow;
@property (nonatomic, assign) unsigned int callID;
@property (nonatomic, assign) CALL_E_TRANSPORTMODE transPortModel;
@property (nonatomic, assign) CALL_E_SRTP_MODE srtpModel;

@property (nonatomic, copy) NSString *anonymousCard;


+ (CCCallService *)shareInstance;

- (BOOL)initTup;

- (BOOL)setSdpWithValue:(int)sdpValue;

- (BOOL)setTacticWithValue:(int)tacticValue;

- (void)startAnonymousCallWithAccessNumber:(NSString *)accessNumber andIp:(NSString *)ip andPort:(NSString *)port;

- (void)configLocalView:(id)localView remoteView:(id)remoteView callId:(unsigned int)callId;

- (BOOL)switchVideoOrient:(int)orient;

- (BOOL)setMicMute:(BOOL)isMute;

- (BOOL)setSpeakerMute:(BOOL)isMute;

- (BOOL)changeAudioRoute:(int)route;

- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate;

- (Stream_INFO)getStreamInfo;

- (BOOL)releaseCall;

- (void)unInitTup;

- (NSInteger)getSpeakerVolume;

- (BOOL)setSpeakerVolume:(int)volume;

@end
