/*
 * Copyright 2015 Huawei Technologies Co., Ltd. All rights reserved.
 * eSDK is licensed under the Apache License, Version 2.0 ^(the "License"^);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"

#define MAINWIDTH ([UIScreen mainScreen].bounds.size.height>[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)
#define MAINHEIGHT ([UIScreen mainScreen].bounds.size.height<[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)

#define BLACK_SUBLAYER_NAME  @"VIDEO_VIEW_BLACK_SUBLAYER"

static EAGLView *openGLPreviewView = nil;
static EAGLView *openGLRemoteView = nil;
static EAGLView *openGLLocalView = nil;
static EAGLView *openGLBFCPView = nil;

@implementation EAGLView


+(EAGLView *)getRemoteVideoViewWithFrame:(CGRect)frame
{
    if (openGLRemoteView == nil)
    {
        openGLRemoteView = [[self alloc] initWithFrame:frame];
        openGLRemoteView.backgroundColor = [UIColor blackColor];
    }
    
	return openGLRemoteView;
}


+(EAGLView *)getLocalVideoViewWithFrame:(CGRect)frame
{
	if (openGLLocalView == nil)
    {
        openGLLocalView = [[self alloc] initWithFrame:frame];
        openGLLocalView.backgroundColor = [UIColor greenColor];
	}
	return openGLLocalView;
}


+ (void)destroyPreviewView
{
    if (openGLPreviewView)
    {
        [openGLPreviewView removeFromSuperview];
        openGLPreviewView = nil;
    }
}

+ (void)destroyLocalView
{
    if (openGLLocalView)
    {
        [openGLLocalView removeFromSuperview];
        openGLLocalView = nil;
    }
}

+ (void)destroyRemoteView
{
    if (!openGLRemoteView)
    {
        return;
    }
    
    [openGLRemoteView removeFromSuperview];
    openGLRemoteView = nil;
}

+ (void)hideRemoteView
{
    [openGLRemoteView addBlackSublayer];
}

+ (void)showRemoteView
{
    [openGLRemoteView deleteBlackSublayer];
}

+ (void)destroyBFCPView
{
    if (openGLBFCPView)
    {
        [openGLBFCPView removeFromSuperview];
        openGLBFCPView = nil;
    }
}

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


- (void)dealloc
{
}


- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
}

- (void)turnoffVideoView
{

        self.layer.transform = CATransform3DMakeScale(-1, 1, 1);
}

// 上下旋转视频视图
- (void)turnUpDownVideoView
{
    self.layer.transform = CATransform3DMakeScale(1, -1, 1);
}

- (void)resetVideoView
{
	self.layer.transform = CATransform3DMakeScale(1, 1, 1);
}

// 清空opengl渲染的内容
- (void)addBlackSublayer
{
    [self deleteBlackSublayer];
    self.layer.masksToBounds = YES;
	CALayer *subLayer = [CALayer layer];
	subLayer.name = BLACK_SUBLAYER_NAME;
	subLayer.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
    //规避iPhone主叫，通话建立后右下半部分为被黑屏遮住
    subLayer.frame = CGRectMake(0, 0, MAINWIDTH, MAINHEIGHT);//设置最大frame
	[self.layer addSublayer:subLayer];
	
}

- (void)deleteBlackSublayer
{
	for (CALayer *sublayer in [self.layer sublayers])
    {
		if ([sublayer.name isEqualToString:BLACK_SUBLAYER_NAME])
        {
			[sublayer removeFromSuperlayer];
            self.layer.masksToBounds = NO;
			break;
		}
	}
	self.layer.doubleSided = TRUE;
}


@end

