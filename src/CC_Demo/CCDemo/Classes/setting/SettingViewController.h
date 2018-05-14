//
//  SettingViewController.h
//  Meeting
//
//  Created by huawei on 16/3/10.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
- (IBAction)vedioSwtichClick:(id)sender;

- (IBAction)voiceSwitchClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *usernameLab;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *getVCodeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeImage;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeText;
@property (weak, nonatomic) IBOutlet UIButton *sendChatClickBtn;
@property (weak, nonatomic) IBOutlet UITableView *chatRecordTabView;
@property (weak, nonatomic) IBOutlet UIButton *sendChatTextBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputChatText;
@property (nonatomic, strong) NSMutableArray *chatdataArray;
@property (weak, nonatomic) IBOutlet UILabel *chatlab;
@property (weak, nonatomic) IBOutlet UIButton *callClickBtn;
@property (weak, nonatomic) IBOutlet UILabel *voiceLab;
@property (weak, nonatomic) IBOutlet UILabel *videoLab;
@property (weak, nonatomic) IBOutlet UISwitch *vocieSwtich;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwtich;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIButton *releaseBtn;
@property (weak, nonatomic) IBOutlet UIButton *releaseCallBtn;


- (IBAction)logoutClick:(id)sender;
- (IBAction)getVCodeClick:(id)sender;
- (IBAction)sendChatClick:(id)sender;
- (IBAction)sendChatTextClick:(id)sender;
- (IBAction)callClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *assBtn;





@end
