//
//  MainViewController.m
//  CCDemo
//
//  Created by Tom on 2017/12/26.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import "MainViewController.h"
#import "VideoController.h"
#import "SettingViewController.h"
#import "DataAssistController.h"
#import "BottomView.h"
#import "MSViewController.h"


@interface MainViewController ()

@property (nonatomic,strong)BottomView *bottomView;

@property (nonatomic,strong)UIScrollView *scrollView;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    
    // Do any additional setup after loading the view.
}

- (void)initView
{
    [self.view addSubview:self.scrollView];
    
    
    self.scrollView.userInteractionEnabled = YES;
    
    
    [self.view addSubview:self.bottomView];
    
    SettingViewController *setVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    setVC.view.x = 0;
    [self addChildViewController:setVC];
    
    [self.scrollView addSubview:setVC.view];
    self.scrollView.scrollEnabled = NO;
    VideoController *videoVC = [[VideoController alloc] init];
    videoVC.view.x = self.view.width;
    [self addChildViewController:videoVC];
    [self.scrollView addSubview:videoVC.view];
    DataAssistController *dataVC = [[DataAssistController alloc] init];
    dataVC.view.x = self.view.width*2;
    [self addChildViewController:dataVC];
    [self.scrollView addSubview:dataVC.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkError:)
                                                 name:@"networkerror"
                                               object:nil];
    
    
    
    
}

- (void)networkError:(NSNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"-5", "") ];
        [self.navigationController popViewControllerAnimated:YES];
        if ([TimeUtil shareInstance].timer) {
            [[TimeUtil shareInstance] stopTimer];
        }
    });
}
- (void)addChildWithController:(UIViewController *)vc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, 64)];
        __weak typeof(self) weakSelf = self;
        _bottomView.indexBlock = ^(int i) {
            switch (i) {
                case 0:
                    [weakSelf.scrollView setContentOffset:CGPointMake(0, 0)];
                    break;
                case 1:
                     [weakSelf.scrollView setContentOffset:CGPointMake(SCREEN_WIdTH, 0)];
                    break;
                case 2:
                     [weakSelf.scrollView setContentOffset:CGPointMake(2*SCREEN_WIdTH, 0)];
                    break;
                default:
                    break;
            }
        };
    }
    return _bottomView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.bottomView.y+64, self.view.width, self.view.height-64)];
        _scrollView.contentSize = CGSizeMake(3*self.view.width, 0);
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.scrollView endEditing:YES];
}

@end
