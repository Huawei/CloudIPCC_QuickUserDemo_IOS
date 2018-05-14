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

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView


+ (EAGLView *)getRemoteVideoViewWithFrame:(CGRect)frame;

+ (EAGLView *)getLocalVideoViewWithFrame:(CGRect)frame;


+ (void)destroyPreviewView;

+ (void)destroyLocalView;

+ (void)destroyRemoteView;

+ (void)destroyBFCPView;

+ (void)hideRemoteView;

+ (void)showRemoteView;

// 左右翻转视频视图
- (void)turnoffVideoView;

// 取消翻转
- (void)resetVideoView;

// 上下旋转视频视图
- (void)turnUpDownVideoView;

// 清空opengl渲染的内容
- (void)addBlackSublayer;

- (void)deleteBlackSublayer;

@end

