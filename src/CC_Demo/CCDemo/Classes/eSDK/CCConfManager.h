//
//  CConfManager.h
//  CCUtil
//
//  Created by on 16/5/9.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCConfInfo.h"
#import "CCConfUserInfo.h"
#import "CCConfCameraInfo.h"
#import "CCICSService.h"


@interface CCConfManager : NSObject
@property (nonatomic, assign) BOOL isNat;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, copy) NSString *serverIp;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, assign) id localWindowView;
@property (nonatomic, assign) id remoteWindowView;
@property (nonatomic, strong) CCConfCameraInfo *localCameraInfo;
@property (nonatomic, strong) CCConfCameraInfo *remoteCameraInfo;
@property (nonatomic, strong) UIImageView *screenView;
@property (nonatomic, strong) UIImageView *fileView;
@property (nonatomic, copy) NSString *msServerIp;
@property (nonatomic, copy) NSString *innerIp;
@property (nonatomic, copy) NSString *outerIp;
@property (nonatomic, assign) TUP_UINT32 selfUserID;
@property (nonatomic, assign) TUP_UINT32 selfDeviceID;
@property (nonatomic, strong) NSMutableArray *cameraInfoArray;//设备列表
@property (nonatomic, strong) NSMutableArray *confUserArray;//当前与会者的列表(userId列表)

+ (CCConfManager *)shareInstance;

- (void)callWith:(NSString *)ip port:(NSString *)port callNum:(NSString *)callNum;

- (void)initConf;

- (BOOL)setVideoMode:(int)mValue;

- (BOOL)setVideoRotate:(VIDEO_ROTATE)rotate;

- (void)unInitConf;

- (BOOL)createConfWithInfo:(CCConfInfo *)info;

- (BOOL)joinConf;

- (BOOL)leaveConf;

- (Stream_INFO)getVideoInfo;

- (BOOL)switchCameraWithIndex:(int)index;

- (BOOL)terminalConf;

@end
