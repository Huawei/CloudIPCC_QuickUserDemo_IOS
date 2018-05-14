//
//  LoginViewController.m
//  CCDemo
//
//  Created by mwx325691 on 16/4/1.
//  Copyright © 2016年 mwx325691. All rights reserved.
//


#import "LoginViewController.h"
#import "SettingViewController.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "MSViewController.h"
#import "CCUtil.h"

//Class CCImpHander;
@interface LoginViewController ()
{
    BOOL _isHTTPS;
    //TPSetViewController *tpView;
    SettingViewController *setView;
    MainViewController *mainVC;
    MSViewController *msVC;
    BOOL _isLogin;
}


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLogin = NO;
    [self initBtnStatus];
   
    self.navigationController.navigationBarHidden = YES;
    [self addNotifications];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadConfig];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view.frame = rect;
}

- (void)initBtnStatus{
    _isLogin = NO;
    //self.envSwitch.enabled = YES;
    self.loginBtn.enabled = YES;
    //self.isHttps.enabled = YES;
    self.isTLS.enabled = YES;
    //self.callBtn.enabled = NO;
    //self.logoutBtn.enabled = NO;
    
    self.ipText.enabled = YES;
    self.portText.enabled = YES;
    //self.vndIdText.enabled = YES;
    self.userNameText.enabled = YES;
    
    self.anonymousNo.enabled = YES;    
    self.domain.enabled=YES;
    self.chatAcode.enabled=YES;
    self.audioAcode.enabled=YES;
    self.SipIpFiled.enabled=YES;
    self.SipPortFiled.enabled=YES;
    
    //[self loadSettingView];
    
}
- (void)updateBtnStatus{
    _isLogin = YES;
    //self.envSwitch.enabled = NO;
    self.loginBtn.enabled = NO;
    //self.isHttps.enabled = NO;
    self.isTLS.enabled = NO;
    
    //self.callBtn.enabled = YES;
    //self.logoutBtn.enabled = YES;
    
    self.ipText.enabled = NO;
    self.portText.enabled = NO;
    //elf.vndIdText.enabled = NO;
    self.userNameText.enabled = NO;
    
    self.anonymousNo.enabled = NO;
    self.domain.enabled=NO;
    self.chatAcode.enabled=NO;
    self.audioAcode.enabled=NO;
    self.SipIpFiled.enabled=NO;
    self.SipPortFiled.enabled=NO;
    
    //[self loadSettingView];
}

- (void)disableBtnStatus{
    //self.envSwitch.enabled = NO;
    self.loginBtn.enabled = NO;
    //self.isHttps.enabled = NO;
    self.isTLS.enabled = NO;
   // self.callBtn.enabled = NO;
    //self.logoutBtn.enabled = NO;
    
    self.ipText.enabled = NO;
    self.portText.enabled = NO;
    //self.vndIdText.enabled = NO;
    self.userNameText.enabled = NO;
    
    self.anonymousNo.enabled = NO;
    self.domain.enabled=NO;
    self.chatAcode.enabled=NO;
    self.audioAcode.enabled=NO;
    self.SipIpFiled.enabled=NO;
    self.SipPortFiled.enabled=NO;
    
    //[self loadSettingView];
}



-(void)loadSettingView
{
    if (setView == nil) {
        setView = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];

        
    }
    if (mainVC == nil) {
        mainVC = [[MainViewController alloc] init];
    }
    msVC = [[MSViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:NO];
    /*
    if (_isLogin)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:@"system is login"];
        
        MSViewController *msViewController = [[MSViewController alloc] init];
        [self.navigationController pushViewController:msViewController animated:NO];
        
    }
    else
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:@"system is not login"];
    
    }
    */
    
    /*if (self.verifyCodeImg.image == nil) {
        [self.refreshBtn setTitle:NSLocalizedString(@"GetCode", "") forState:UIControlStateNormal];
    }else
    {
        [self.refreshBtn setTitle:@"" forState:UIControlStateNormal];
    }
  
    if (tpView == nil) {
        tpView =[[TPSetViewController alloc] initWithNibName:@"TPSetViewController" bundle:nil];
    }
    if (setView == nil) {
        setView= [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    }
    
    for (UIView *view in self.settingView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_isLogin)
    {        
        [self.refreshBtn setHidden:NO];
        [self.verifyCodeImg setHidden:NO];
        [self.verifyText setHidden:NO];
    }
    else
    {
        [self.refreshBtn setHidden:YES];
        [self.verifyCodeImg setHidden:YES];
        [self.verifyText setHidden:YES];
    }
    
    [self.sipView setHidden:YES];
    
    if (self.envSwitch.on) {
        [self.isTLS setHidden:YES];
        [self.tlslab setHidden:YES];
        if (_isLogin)
        {
            [self.sipView setHidden:NO];
             setView.view.frame =  CGRectMake(0, 0, self.settingView.frame.size.width,self.settingView.frame.size.height );
            [self.settingView addSubview:setView.view];
            
        }
        
    }
    else
    {
        [self.isTLS setHidden:NO];
        [self.tlslab setHidden:NO];
        if (_isLogin)
        {
            tpView.view.frame =  CGRectMake(0, 0, self.settingView.frame.size.width,self.settingView.frame.size.height );
            [self.settingView addSubview:tpView.view];
        }
    }
     */
    
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResult:)
                                                 name:AUTH_MSG_ON_LOGIN
                                               object:nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(logoutResult:)
                                                 name:AUTH_MSG_ON_LOGOUT
                                               object:nil];
    */
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showVerifyCode:)
                                                 name:CALL_GET_VERIFY_CODE
                                               object:nil];*/
    
}

-(void)onKeyBoardWillShow:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSNumber *duration = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.view.frame = CGRectMake(0, -50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
}
-(void)onKeyBoardWillHide:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSNumber *duration = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
}

- (void)loadConfig{
    [[LoginInfo sharedInstance] loadConfig];

    self.ipText.text = [LoginInfo sharedInstance].MSLoginIp;
    self.portText.text = [LoginInfo sharedInstance].MSLoginPort;
    _isHTTPS = [LoginInfo sharedInstance].isMSHTTPS;
    self.SipIpFiled.text = [LoginInfo sharedInstance].MSSipIp;
    self.SipPortFiled.text = [LoginInfo sharedInstance].MSSipPort;
    self.anonymousNo.text = [LoginInfo sharedInstance].anonymousNo;
    self.chatAcode.text = [LoginInfo sharedInstance].MSChatACode;
    self.audioAcode.text = [LoginInfo sharedInstance].MSAudioACode;
    self.domain.text = [LoginInfo sharedInstance].domain;
    [self.isTLS setOn:[LoginInfo sharedInstance].isTLS];
   // self.portText.text = @"8243";
    self.userNameText.text = [LoginInfo sharedInstance].loginUser;
    self.vndIdtext.text = [LoginInfo sharedInstance].vdnId;
   [self.vndIdLab setText:NSLocalizedString(@"vndId", "")];
    [self.loginBtn setTitle:NSLocalizedString(@"Login", "") forState:UIControlStateNormal];
   // [self.logoutBtn setTitle:NSLocalizedString(@"Logout", "") forState:UIControlStateNormal];
   // [self.callBtn setTitle:NSLocalizedString(@"Call", "") forState:UIControlStateNormal];
    [self.loginIpLab setText:NSLocalizedString(@"LoginIP", "")];
    [self.portLab setText:NSLocalizedString(@"LoginPort", "")];
    [self.sipIpLab setText:NSLocalizedString(@"SipServerIP", "")];
    [self.sipPortLab setText:NSLocalizedString(@"SipServerPort", "")];
    [self.userNameLab setText:NSLocalizedString(@"userName", "")];
    [self.anoymousNoLab setText:NSLocalizedString(@"anoymousNo", "")];
    [self.domainLab setText:NSLocalizedString(@"domain", "")];
    [self.chatAcodeLab setText:NSLocalizedString(@"ChatAcessCode", "")];
    [self.audioAcodeLab setText:NSLocalizedString(@"AudioAcessCode", "")];
    [self.configLab setText:NSLocalizedString(@"Configuration", "")];
    // [self.vndIdLab setText:NSLocalizedString(@"vndId", "")];
    [self initBtnStatus];
    
}


- (void)loginResult:(NSNotification *)notify
{
    NSString *loginResult = (NSString *)notify.object;
    NSString *success = [NSString stringWithFormat:@"%ld",(long)SUCCESS_LOGIN];
    if ([success isEqualToString: loginResult])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self updateBtnStatus];
            _isLogin = YES;
            [self loadSettingView];
            
        });
        NSLog(@"login sucess");
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self initBtnStatus];
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"LoginResult", ""),NSLocalizedString(loginResult, "")]];
    });
    
    
}

- (void)logoutResult:(NSNotification *)notify
{
    NSString *logoutResult  = (NSString *)notify.object;
    NSLog(@"logoutResult : %@",logoutResult);

    if ( [logoutResult intValue]==SUCCESS_LOGOUT) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initBtnStatus];
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                               content:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"LogoutResult", ""),logoutResult]];
         [self initBtnStatus];
    });
}

- (IBAction)loginClick:(id)sender {
   
    BOOL isLoginIPVaild = self.ipText.text.length > 0;
    if (!isLoginIPVaild)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"IP", "")];
        return;
    }
    
    BOOL isLoginPortValid = [CCDemoUtil isPortValid:self.portText.text];
    if (!isLoginPortValid)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"Port", "")];
        return;
    }
    
    /*if( self.vndIdText.text.length <= 0 )
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"vndIdError", "")];
        return;
    }
    */
    if ([self.userNameText.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"userNameError", "") ];
        return;
    }

    if ([self.anonymousNo.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"anonymousNoError", "") ];
        return;
    }
    
    if ([self.domain.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"domainError", "") ];
        return;
    }

    
    if ([self.chatAcode.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"chatAcodeError", "") ];
        return;
    }
    
    if ([self.audioAcode.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"audioAcodeError", "") ];
        return;
    }
    
    if ([self.SipIpFiled.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"SipIpFiledError", "") ];
        return;
    }
    if ([self.SipPortFiled.text length] == 0)
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"SipPortFiledError", "") ];
        return;
    }
    
    [LoginInfo sharedInstance].isTLS = self.isTLS.on;
    
    _isHTTPS = YES;//self.isHttps.on;
    
    int serverType = SERVER_TYPE_MS;//-1;
    /*if ([self.envSwitch isOn])
    {
        serverType = SERVER_TYPE_MS;
    }
    else
    {
        serverType = SERVER_TYPE_TP;
    }
    */
    [self tpLoginSave];
    
    NSInteger ret =  [[CCUtil shareInstance] setHostAddress:self.ipText.text
                                     port:self.portText.text
                            transSecurity:_isHTTPS
                            sipServerType:serverType];
    
    
    if (ret != RET_OK)
    {
         [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"ParamError", "param is invalid")];
        return;
    }
    
    if (_isHTTPS)
    {
        NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"der"];
        NSData *dataCA  = [NSData dataWithContentsOfFile:cerPath];
        [[CCUtil shareInstance] setNeedValidate:NO needValidateDomain:NO certificateData:dataCA];
    }
    
    [[CCUtil shareInstance] setSIPServerAddress:[LoginInfo sharedInstance].MSSipIp port:[LoginInfo sharedInstance].MSSipPort];
    
    NSInteger result =  [[CCUtil shareInstance] login:self.vndIdtext.text userName:self.userNameText.text];
    if (result != RET_OK)
    {
        
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"ParamError", "param is invalid")];
        return;
    }else
    {
    }
        
    [self disableBtnStatus];
}




/*
- (IBAction)callclick:(id)sender {
    
    if (self.envSwitch.on)
    {
        
        BOOL isSipIPVaild = self.SipIpFiled.text.length>0 && [CCDemoUtil isPortValid:self.SipPortFiled.text] && [CCDemoUtil isAcodeValid:setView.chatAcodeFiled.text] && [CCDemoUtil isAcodeValid:setView.audioAcodeFiled.text];
        if (!isSipIPVaild)
        {
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"ParamError", "")];
            return;
        }
        setLogPath
        [LoginInfo sharedInstance].MSSipIp = self.SipIpFiled.text;
        [LoginInfo sharedInstance].MSSipPort = self.SipPortFiled.text;

        [LoginInfo sharedInstance].MSChatACode = setView.chatAcodeFiled.text;
        [LoginInfo sharedInstance].MSAudioACode = setView.audioAcodeFiled.text;
        [LoginInfo sharedInstance].MSCallData = setView.callDataFiled.text;
        [LoginInfo sharedInstance].VCode = self.verifyText.text;
        
        [[LoginInfo sharedInstance] saveConfig];
        
        MSViewController *msViewController = [[MSViewController alloc] init];
        [self.navigationController pushViewController:msViewController animated:NO];
        return;
    }
    
    BOOL isAcodeValid = [CCDemoUtil isAcodeValid:tpView.aCodeTextFiled.text];
    if (!isAcodeValid )
    {
        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"ACode", "")];
        return;
    }
    [LoginInfo sharedInstance].TPACode = tpView.aCodeTextFiled.text;
    [LoginInfo sharedInstance].TPCallData = tpView.callDataTextFiled.text;
    [LoginInfo sharedInstance].VCode = self.verifyText.text;
    
    [[LoginInfo sharedInstance] saveConfig];
    
    TPViewController * tpViewController = [[TPViewController alloc] init];
 
    [self.navigationController pushViewController:tpViewController animated:NO];
   
}

*/


/*
- (IBAction)choice:(id)sender {
    [self loadConfig];
    [self loadSettingView];
}

- (IBAction)isHttpsClick:(id)sender {
    if (self.isHttps.on) {
        self.portText.text = @"8243";
    }
    else{
        self.portText.text = @"8280";
    }
}
*/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)tpLoginSave
{
    //if ([self.envSwitch isOn]){
    
    [LoginInfo sharedInstance].MSLoginIp = self.ipText.text;
    [LoginInfo sharedInstance].MSLoginPort = self.portText.text;
        
    [LoginInfo sharedInstance].isMSHTTPS = YES;//self.isHttps.on;
    [LoginInfo sharedInstance].MSChatACode = self.chatAcode.text;
    
    [LoginInfo sharedInstance].MSAudioACode = self.audioAcode.text;
    [LoginInfo sharedInstance].MSChatACode = self.chatAcode.text;
    [LoginInfo sharedInstance].MSSipIp = self.SipIpFiled.text;
    [LoginInfo sharedInstance].MSSipPort = self.SipPortFiled.text;
    [LoginInfo sharedInstance].anonymousNo = self.anonymousNo.text;
    [LoginInfo sharedInstance].domain = self.domain.text;
    [LoginInfo sharedInstance].isTLS = self.isTLS.on;
    [LoginInfo sharedInstance].loginUser = self.userNameText.text;
    [LoginInfo sharedInstance].vdnId = self.vndIdtext.text;
    [[LoginInfo sharedInstance] saveConfig];
        
   /* }
    else
    {
        [LoginInfo sharedInstance].TPLoginIp = self.ipText.text;
        [LoginInfo sharedInstance].TPLoginPort = self.portText.text;
        
        [LoginInfo sharedInstance].isTPHTTPS = self.isHttps.on;
        [[LoginInfo sharedInstance] saveConfig];
    }
    */
}
/*
- (IBAction)refreshBtnClick:(id)sender {
    [[CCUtil shareInstance] getVerifyCode];
}


- (void)showVerifyCode:(NSNotification *)notify
{
    if ([notify.object intValue] == 0) {
        NSString *encodedImageStr = [notify.userInfo objectForKey:@"verifyCode"];
        NSData *decodedImageData   =  [[NSData alloc] initWithBase64EncodedString:encodedImageStr options:0];
        
        UIImage *decodedImage= [UIImage imageWithData:decodedImageData];
        
        NSLog(@"===Decoded image size: %@", NSStringFromCGSize(decodedImage.size));
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"decodedImage :%@",decodedImage);
            [self.verifyCodeImg setImage:decodedImage];
            [self.refreshBtn setTitle:@"" forState:UIControlStateNormal];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "")
                                   content:NSLocalizedString(@"GetCodeError", "")];
        });
        
        
    
    

}

}
 */
@end
