//
//  LoginViewController.h
//  CCDemo
//
//  Created by mwx325691 on 16/4/1.
//  Copyright © 2016年 mwx325691. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPViewController.h"
#import "MSViewController.h"


@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *vndIdLab;

//@property (weak, nonatomic) IBOutlet UISwitch *envSwitch;
@property (weak, nonatomic) IBOutlet UITextField *ipText;
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
//@property (weak, nonatomic) IBOutlet UITextField *vndIdText;

//@property (weak, nonatomic) IBOutlet UIButton *callBtn;
//@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
//@property (weak, nonatomic) IBOutlet UIView *settingView;
//@property (weak, nonatomic) IBOutlet UIView *sipView;
//@property (weak, nonatomic) IBOutlet UISwitch *isHttps;
@property (weak, nonatomic) IBOutlet UISwitch *isTLS;
//@property (weak, nonatomic) IBOutlet UILabel *vndIdLab;
@property (weak, nonatomic) IBOutlet UITextField *anonymousNo;
@property (weak, nonatomic) IBOutlet UITextField *vndIdtext;

@property (weak, nonatomic) IBOutlet UITextField *domain;
@property (weak, nonatomic) IBOutlet UILabel *configLab;

@property (weak, nonatomic) IBOutlet UITextField *chatAcode;
@property (weak, nonatomic) IBOutlet UITextField *audioAcode;


@property (weak, nonatomic) IBOutlet UITextField *SipIpFiled;

@property (weak, nonatomic) IBOutlet UITextField *SipPortFiled;
@property (weak, nonatomic) IBOutlet UILabel *loginIpLab;
@property (weak, nonatomic) IBOutlet UILabel *portLab;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UILabel *sipIpLab;
@property (weak, nonatomic) IBOutlet UILabel *sipPortLab;
@property (weak, nonatomic) IBOutlet UILabel *chatAcodeLab;
@property (weak, nonatomic) IBOutlet UILabel *audioAcodeLab;
@property (weak, nonatomic) IBOutlet UILabel *anoymousNoLab;
@property (weak, nonatomic) IBOutlet UILabel *domainLab;

//@property (weak, nonatomic) IBOutlet UIButton *Logout;

//@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeImg;
//@property (weak, nonatomic) IBOutlet UITextField *verifyText;
@property (weak, nonatomic) IBOutlet UILabel *tlslab;

- (IBAction)loginClick:(id)sender;
//- (IBAction)callclick:(id)sender;
//- (IBAction)logoutClick:(id)sender;
//- (IBAction)choice:(id)sender;
//- (IBAction)isHttpsClick:(id)sender;
//- (IBAction)refreshBtnClick:(id)sender;


@end
