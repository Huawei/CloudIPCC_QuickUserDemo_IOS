//
//  CCRequestClient.h
//  CCSDK
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestResponseDelegate <NSObject>

/**
 *  收到http/https错误响应之后的回调
 *
 *  @param errorDict
 */
-(void)handleResponseError:(NSDictionary *)errorDict;

/**
 *  收到http/https响应数据完成后的响应
 *
 *  @param data
 */
-(void)handleResponseData:(NSDictionary *)returnDict;

/**
 *  收到http/https响应时候的回调
 *
 *  @param httpResponse
 */
-(void)handleResponseHeader:(NSHTTPURLResponse*)httpResponse;

@end

@interface CCRequestClient : NSObject<NSURLSessionDataDelegate,NSURLSessionDelegate>

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) NSString *requestURLString;
@property (nonatomic, assign) id<RequestResponseDelegate> delegate;

-(instancetype)initWithURL:(NSString*)urlString;
-(void)startRequest;

@end



