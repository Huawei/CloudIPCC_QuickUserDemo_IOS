//
//  VideoController.m
//  CCDemo
//
//  Created by Tom on 2017/12/26.
//  Copyright © 2017年 mwx325691. All rights reserved.
//

#import "VideoController.h"
#import "EAGLView.h"
#import "CCCallService.h"

@interface VideoController ()

{
    NSInteger _rotate;
    BOOL _isBackCamera;
    
    
}

@property (nonatomic, strong) EAGLView *remoteViewScreen;

@property (nonatomic, strong) EAGLView *localViewScreen;

@property (nonatomic,strong) UIButton *switchBtn;

@property (nonatomic,strong) UIButton *transformBtn;
@property (nonatomic,strong) UIButton *transformBtn1;
@property (nonatomic,strong) UIButton *transformBtn2;
@property (nonatomic,strong) UIButton *transformBtn3;




@end

@implementation VideoController




- (void)viewDidLoad {
    [super viewDidLoad];
     _rotate = 270;
    _isBackCamera = YES;
    [self addNotification];
    
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:@"updateView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletelayer) name:@"deletelayer" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rorataVideo) name:@"rorataVideo" object:nil];
    
}

- (void)rorataVideo
{
    
}

- (void)deletelayer
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (2.0 * NSEC_PER_SEC));
    dispatch_after(time, queue, ^{
        [self.remoteViewScreen deleteBlackSublayer];
    });
}
- (void)rotateTransformClick
{
    
    _rotate = _rotate+ 90;
    if (_rotate > 270)
    {
        _rotate = 0;
    }
    [[CCUtil shareInstance] setVideoRotate:_rotate];
    
}

- (void)updateView
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.remoteViewScreen = [[EAGLView alloc] initWithFrame:CGRectMake(0, 0, 190, 245)];
//        self.localViewScreen = [[EAGLView alloc] initWithFrame:CGRectMake(190, 0, 190, 245)];
//        //            self.remoteViewScreen.userInteractionEnabled = YES;
//        self.remoteViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        self.localViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        self.remoteViewScreen.backgroundColor = [UIColor blackColor];
//        self.localViewScreen.backgroundColor = [UIColor blackColor];
//        [CCCallService shareInstance].localViewWindow = self.localViewScreen;
//        [CCCallService shareInstance].remoteViewWindow = self.remoteViewScreen;
    });
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callSuccess:)
                                                 name:CALL_MSG_ON_CONNECTED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callEnd:)
                                                 name:CALL_MSG_ON_DISCONNECTED object:nil];
}

#pragma mark-呼叫成功点击通话成功通知
- (void)callSuccess:(NSNotification *)notify
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
    NSString *result = notify.object;
    
    if ([result isEqualToString:AUDIO_CALL])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
           
        });
        
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self.localViewScreen deleteBlackSublayer];
           
            [[CCUtil shareInstance] switchCamera:1];
            [[CCUtil shareInstance] setVideoRotate:270];
           
           
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.remoteViewScreen deleteBlackSublayer];
            TUP_RESULT rotateRet  = tup_call_set_capture_rotation([CCCallService shareInstance].callID, 1, 3);
            logDbg(@"tup_call_set_capture_rotation:%d",rotateRet);
            
            
        });
       
        
       
    }
    else
    {
        NSLog(@"chat success reslut:%@",result);
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
        });
    }
   
}
#pragma mark-呼叫结束通知
- (void)callEnd:(NSNotification *)notify
{
    NSString *result = (NSString *)notify.object;

    if ([result isEqualToString:AUDIO_CALL])
    {
        NSLog(@"call audio end");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
          
        });
        /* if (_audioSuccess)
         {
         _audioSuccess = NO;
         dispatch_async(dispatch_get_main_queue(), ^{
         [self.audionBtn setTitle:NSLocalizedString(@"Audio", "") forState:UIControlStateNormal];
         });当前已有呼叫
         }
         */
    }
    else if ([result isEqualToString:VIDEO_CALL])
    {
        //[self videoEnd];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.remoteViewScreen addBlackSublayer];
                [self.localViewScreen addBlackSublayer];
            });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
        
    }
}


-(void)initView
{
    self.remoteViewScreen = [EAGLView getRemoteVideoViewWithFrame:CGRectMake(0, 0, 190, 245)];
    self.localViewScreen = [EAGLView getLocalVideoViewWithFrame:CGRectMake(190, 0, 190, 245)];
//    self.remoteViewScreen.userInteractionEnabled = YES;
    self.remoteViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.localViewScreen.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
//    [self.remoteViewScreen addBlackSublayer];
//    [self.localViewScreen addBlackSublayer];
    [self.view addSubview:self.remoteViewScreen];
    [self.view addSubview:self.localViewScreen];
//    [self.view bringSubviewToFront:self.remoteViewScreen];
//    [self.view bringSubviewToFront:self.localViewScreen];
    
    [self.view addSubview:self.switchBtn];
    [self.view addSubview:self.transformBtn];
   
    [[CCUtil shareInstance] setVideoContainer:self.localViewScreen remoteView:self.remoteViewScreen];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rotateClick
{
    
//    if (!_videoSuccess)
//    {
//        [CCDemoUtil showAlertWithTitle:NSLocalizedString(@"Remind", "") content:NSLocalizedString(@"NoVideo", "")];
//        return;
//    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(cameraSwitch) object:nil];
    [self performSelector:@selector(cameraSwitch) withObject:nil afterDelay:1.0];
}

- (void)cameraSwitch
{
    if (_isBackCamera)
    {
        [[CCUtil shareInstance] switchCamera:1];
        _isBackCamera = NO;
        return;
    }
    [[CCUtil shareInstance] switchCamera:0];
    _isBackCamera = YES;
}

- (UIButton *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.localViewScreen.y+self.localViewScreen.height, 100, 40)];
        _switchBtn = [CCustom butnWithFrame:CGRectMake(0, self.localViewScreen.y+self.localViewScreen.height, 100, 40) title:@"切换摄像头" fontSize:13];
        [_switchBtn addTarget:self action:@selector(rotateClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _switchBtn;
}

- (UIButton *)transformBtn
{
    if (!_transformBtn) {
        _transformBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.localViewScreen.y+self.localViewScreen.height, 100, 40)];
        _transformBtn = [CCustom butnWithFrame:CGRectMake(self.switchBtn.width+5, self.localViewScreen.y+self.localViewScreen.height, 100, 40) title:@"旋转90度" fontSize:13];
        [_transformBtn addTarget:self action:@selector(rotateTransformClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _transformBtn;
}


@end
