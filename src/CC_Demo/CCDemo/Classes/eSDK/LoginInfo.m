//
//  LoginInfo.h
//  AGDemo
//
//  Created by mwx325691 on 2016/10/14.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "LoginInfo.h"


static NSString * const DEFAULT_TPLOGINIP = @"172.22.8.99";
static NSString * const DEFAULT_TPLOGINPORT = @"8243";
NSString *const keyTPLoginIP = @"TP_LOGIN_IP";
NSString *const keyTPLoginPort = @"TP_LOGIN_PORT";

static NSString * const DEFAULT_TPACCESSCODE = @"1007";
NSString *const keyTPACode = @"TP_ACCESSCODE";

static NSString * const DEFAULT_TPCALLDATA = @"";
NSString *const keyTPCALLDATA = @"TP_CALL_DATA";

//172.22.8.99 8243
static NSString * const DEFAULT_MSLOGINIP = @"172.19.26.187";
static NSString * const DEFAULT_MSLOGINPORT = @"8243";
NSString *const keyMSLoginIP = @"MS_LOGIN_IP";
NSString *const keyMSLoginPort = @"MS_LOGIN_PORT";

//172.22.10.73 5060
static NSString * const DEFAULT_SIPIP = @"172.19.26.216";
static NSString * const DEFAULT_SIPPORT = @"5060";
NSString *const keyMSSipIP = @"MS_SIP_IP";
NSString *const keyMSSipPort = @"MS_SIP_PORT";

static NSString * const DEFAULT_MSCHATACODE = @"6061";
static NSString * const DEFAULT_MSAUDIOACODE = @"6062";
NSString *const keyMSCHATACODE = @"MS_CHAT_ACODE";
NSString *const keyMSAUDIOACODE = @"MS_AUDIO_ACODE";

static NSString * const DEFAULT_MSCALLDATA = @"";
NSString *const keyMSCALLDATA = @"MS_CALL_DATA";

static NSString * const DEFAULT_DOMAIN = @"CloudEC.com";
NSString *const keyDomain= @"DOMAIN";

static NSString * const DEFAULT_ANOYMOUSNO = @"AnoymousCard";
NSString *const keyAnoymousNo = @"ANOYMOUSNO";

static NSString * const DEFAULT_USER = @"Userdemo";
NSString *const keyLoginUser= @"LOGINUSER";

static NSString * const DEFAULT_VNDID = @"1";
NSString *const keyVndid= @"VNDID";

@implementation LoginInfo

static LoginInfo *loginInfo = nil;

+(LoginInfo *)sharedInstance
{
    @synchronized(self){
        if (loginInfo == nil)
        {
            loginInfo = [[LoginInfo alloc] init];
        }
    }
    return loginInfo;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isTPHTTPS = YES;
        self.isMSHTTPS = YES;
        self.isTLS = YES;
        self.VCode = @"";
    }
    return self;
}


-(void)loadConfig
{
    NSString *filePath = [self configFilePath];
    NSFileManager *defultManager = [NSFileManager defaultManager];
    NSDictionary *configDic = [NSDictionary dictionary];
    if ([defultManager fileExistsAtPath:filePath]) {
        configDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    if (configDic)
    {
        
        self.MSLoginIp = [configDic objectForKey:keyMSLoginIP];
        self.MSLoginPort = [configDic objectForKey:keyMSLoginPort];
        self.MSChatACode = [configDic objectForKey:keyMSCHATACODE];
        self.MSAudioACode = [configDic objectForKey:keyMSAUDIOACODE];
        self.MSSipIp = [configDic objectForKey:keyMSSipIP];
        self.MSSipPort = [configDic objectForKey:keyMSSipPort];
        self.MSCallData = [configDic objectForKey:keyMSCALLDATA];
        self.domain = [configDic objectForKey:keyDomain];
        self.anonymousNo = [configDic objectForKey:keyAnoymousNo];
        self.loginUser = [configDic objectForKey:keyLoginUser];
        self.vdnId = [configDic objectForKey:keyVndid];
        
    }
    else
    {
       
        self.MSLoginIp = DEFAULT_MSLOGINIP;
        self.MSLoginPort = DEFAULT_MSLOGINPORT;
        self.MSChatACode = DEFAULT_MSCHATACODE;
        self.MSAudioACode = DEFAULT_MSAUDIOACODE;
        self.MSSipIp = DEFAULT_SIPIP;
        self.MSSipPort = DEFAULT_SIPPORT;
        self.MSCallData = DEFAULT_MSCALLDATA;
        self.domain = DEFAULT_DOMAIN;
        self.anonymousNo = DEFAULT_ANOYMOUSNO;
        self.loginUser = DEFAULT_USER;
        self.vdnId = DEFAULT_VNDID;
    }
    //self.TPACode = DEFAULT_TPACCESSCODE;
    
   // BOOL isNil1 = (self.TPLoginIp.length == 0 && self.TPLoginPort.length == 0);
  //  BOOL isNil2 = (self.TPCallData.length == 0 && self.MSLoginIp.length == 0 && self.MSLoginPort == 0);
    BOOL isNil1 = (self.MSChatACode.length == 0 && self.MSAudioACode.length == 0 && self.MSSipIp.length == 0);
    BOOL isNil2 = (self.MSSipPort.length == 0 && self.MSCallData.length == 0);
    if (isNil1 && isNil2 ) {
       // self.TPLoginIp = DEFAULT_TPLOGINIP;
        //self.TPLoginPort = DEFAULT_TPLOGINPORT;
        
        self.MSLoginIp = DEFAULT_MSLOGINIP;
        self.MSLoginPort = DEFAULT_MSLOGINPORT;
        self.MSChatACode = DEFAULT_MSCHATACODE;
        self.MSAudioACode = DEFAULT_MSAUDIOACODE;
        self.MSSipIp = DEFAULT_SIPIP;
        self.MSSipPort = DEFAULT_SIPPORT;
        self.MSCallData = DEFAULT_MSCALLDATA;
        self.domain = DEFAULT_DOMAIN;
        self.anonymousNo = DEFAULT_ANOYMOUSNO;
        self.loginUser = DEFAULT_USER;
        self.vdnId = DEFAULT_VNDID;
    }

}

-(void)saveConfig
{
    NSMutableDictionary *currentConfigDict = [NSMutableDictionary dictionary];
    //[currentConfigDict setObject:[self getNotNilStr:self.TPLoginIp] forKey:keyTPLoginIP];
    //[currentConfigDict setObject:[self getNotNilStr:self.TPLoginPort] forKey:keyTPLoginPort];
    
    [currentConfigDict setObject:[self getNotNilStr:self.MSLoginIp] forKey:keyMSLoginIP];
    [currentConfigDict setObject:[self getNotNilStr:self.MSLoginPort] forKey:keyMSLoginPort];
    [currentConfigDict setObject:[self getNotNilStr:self.MSSipIp] forKey:keyMSSipIP];
    [currentConfigDict setObject:[self getNotNilStr:self.MSSipPort] forKey:keyMSSipPort];
    [currentConfigDict setObject:[self getNotNilStr:self.MSChatACode] forKey:keyMSCHATACODE];
    [currentConfigDict setObject:[self getNotNilStr:self.MSAudioACode] forKey:keyMSAUDIOACODE];
    [currentConfigDict setObject:[self getNotNilStr:self.MSCallData] forKey:keyMSCALLDATA];
    [currentConfigDict setObject:[self getNotNilStr:self.anonymousNo] forKey:keyAnoymousNo];
    [currentConfigDict setObject:[self getNotNilStr:self.domain] forKey:keyDomain];
    [currentConfigDict setObject:[self getNotNilStr:self.loginUser] forKey:keyLoginUser];
    [currentConfigDict setObject:[self getNotNilStr:self.vdnId] forKey:keyVndid];
    NSString *configFilePath = [self configFilePath];
    [currentConfigDict writeToFile:configFilePath atomically:YES];
    [[CCUtil shareInstance] setTransportSecurityUseTLS:[LoginInfo sharedInstance].isTLS useSRTP:[LoginInfo sharedInstance].isTLS];
}
- (NSString*)getNotNilStr:(NSString*)orignalStr
{
    NSString *resultStr = @"";
    if ([orignalStr length] > 0)
    {
        resultStr = [NSString stringWithString:orignalStr];
    }
    return resultStr;
}
-(NSString*)configFilePath
{
    NSArray * docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPathArray objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"userConfig.plist"];
    return filePath;
}
@end
