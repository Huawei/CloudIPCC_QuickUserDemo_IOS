//
//  CCICSService.h
//  CCSDK
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCRequestClient.h"
#import "CCSDK.h"

@interface CCICSService : NSObject<RequestResponseDelegate>

@property (nonatomic, copy) NSString *callID;
@property (nonatomic, assign) BOOL isBind;
@property (nonatomic, assign) BOOL isLogout;


+ (CCICSService *)shareInstance;

- (void)makeCallConnection:(NSString *)accessCode callType:(NSString *)callType callData:(NSString *)callData verifyCode:(NSString *)verifyCode;

- (void)webChatCallWithAccessCode:(NSString *)accessCode callData:(NSString *)callData verifyCode:(NSString *)verifyCode;

- (void)applyMeetingWithCallId:(NSString *)callId;

- (void)sendWithMsg:(NSString *)message;

- (void)getQueueInfo;

- (void)dropCall;

- (void)releaseWebChatCall;

- (void)getEvent;

- (void)stopMeeting;

-(void)getVerifyCode;

- (void)requestWithUrlstring:(NSString *)url requestBody:(NSData *)body method:(NSString *)method isGuid:(BOOL)isGuid;

@end
