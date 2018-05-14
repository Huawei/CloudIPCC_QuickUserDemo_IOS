//
//  LoginInfo.h
//  AGDemo
//
//  Created by mwx325691 on 2016/10/14.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject


//@property (nonatomic, copy) NSString *TPLoginIp;
//@property (nonatomic, copy) NSString *TPLoginPort;
//@property (nonatomic, copy) NSString *TPACode;
//@property (nonatomic, copy) NSString *TPCallData;

@property (nonatomic, copy) NSString *MSLoginIp;
@property (nonatomic, copy) NSString *MSLoginPort;
@property (nonatomic, copy) NSString *MSChatACode;
@property (nonatomic, copy) NSString *MSAudioACode;
@property (nonatomic, copy) NSString *MSSipIp;
@property (nonatomic, copy) NSString *MSSipPort;
@property (nonatomic, copy) NSString *MSCallData;
@property (nonatomic, copy) NSString *anonymousNo;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *loginUser;
@property (nonatomic, copy) NSString *vdnId;
@property (nonatomic, assign) BOOL isTPHTTPS;
@property (nonatomic, assign) BOOL isMSHTTPS;
@property (nonatomic, assign) BOOL isTLS;
@property (nonatomic, copy) NSString *VCode;



+(LoginInfo *)sharedInstance;

-(void)loadConfig;

-(void)saveConfig;

@end
