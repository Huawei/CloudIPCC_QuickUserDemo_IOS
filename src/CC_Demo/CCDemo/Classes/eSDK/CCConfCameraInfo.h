//
//  CConfCameraInfo.h
//  CCUtil
//
//  Created by  on 16/5/10.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tup_def.h"

@interface CCConfCameraInfo : NSObject

@property (nonatomic, assign) TUP_UINT32 userID;//组件是当作NodeID,UI层当作是UserID
@property (nonatomic, assign) TUP_UINT32 deviceID;//设备ID
@property (nonatomic, copy) NSString *deviceName;//设备名字
@property (nonatomic, assign) TUP_UINT16 deviceType;//设备的类型(摄像头，智真，电话)
@property (nonatomic, assign) id videoView;

@end
