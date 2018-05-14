//
//  CCRequestClient.m
//  CCUtil
//
//  Created by  on 16/3/31.
//  Copyright © 2016年 . All rights reserved.
//

#import "CCRequestClient.h"
#import "CCDefineHead.h"
#import "CCLogger.h"
#import "CCConstantInfo.h"

const NSTimeInterval REQUEST_TIME_OUT = 20;

@interface CCRequestClient()
{
    NSMutableData *_receiveData;
    NSURLSessionDataTask *_dataTask;
}
@end

@implementation CCRequestClient

-(instancetype)initWithURL:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        _receiveData = [NSMutableData data];
        self.requestURLString = [urlString copy];
    }
    return self;
}

-(void)startRequest
{
    NSURLRequest *urlRequest = nil;
    NSURL *url = [NSURL URLWithString:self.requestURLString];
    if (!self.request)
    {
        urlRequest = [NSURLRequest requestWithURL:url];
    }
    else
    {
        urlRequest = self.request;
    }

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    _dataTask = [session dataTaskWithRequest:urlRequest];
    [_dataTask resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        __block NSURLCredential *credential = nil;
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        //是否验证证书
        BOOL isNeedValidate = [CCConstantInfo shareInstance].needValidate;
        if (!isNeedValidate)
        {
            //only check against the certs I provide
            SecTrustSetAnchorCertificatesOnly(serverTrust, YES);
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential)
            {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            if (completionHandler)
            {
                completionHandler(disposition, credential);
            }
            return;
        }
        
        NSString *domain = challenge.protectionSpace.host;
        BOOL needValidateDomainName = [CCConstantInfo shareInstance].isNeedValidateDomainName;
        NSMutableArray *policies = [[NSMutableArray alloc] init];
        //需要验证域名时，需要添加一个验证域名的策略
        if (needValidateDomainName && domain)
        {
            [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
        }
        else
        {
            [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
        }
        
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
        OSStatus err = errSecSuccess;
        SecTrustResultType  trustResult = kSecTrustResultInvalid;
        
        NSData * cerData = [CCConstantInfo shareInstance].dataCA;
        if (cerData)
        {
            SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(cerData));
            NSArray *trustedCertificates = [NSArray arrayWithObject:(__bridge id)certificate];
            //将读取的证书设置为serverTrust的根证书
            err = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)trustedCertificates);
            CFRelease(certificate);
            if(err == noErr)
            {
                SecTrustSetAnchorCertificatesOnly(serverTrust, NO);
                // 验证服务器证书
                err = SecTrustEvaluate(serverTrust, &trustResult);
            }
            if (err == errSecSuccess && (trustResult == kSecTrustResultProceed || trustResult == kSecTrustResultUnspecified))
            {
                //认证成功，则创建一个凭证返回给服务器
                disposition = NSURLSessionAuthChallengeUseCredential;
                credential = [NSURLCredential credentialForTrust:serverTrust];
            }
            else
            {
                if (trustResult ==  kSecTrustResultRecoverableTrustFailure)
                {
                    logDbg(@"server certificate verify fail,trustResult:kSecTrustResultRecoverableTrustFailured");
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            }
            //安装证书
            if (completionHandler)
            {
                completionHandler(disposition, credential);
            }
        }
        else
        {
            SecTrustSetAnchorCertificatesOnly(serverTrust, YES);
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential)
            {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
            if (completionHandler)
            {
                completionHandler(disposition, credential);
            }
        }
    }
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (self.delegate)
    {
        [self.delegate handleResponseHeader:httpResponse];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (data)
    {
        [_receiveData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSString *relativePath = task.originalRequest.URL.relativePath;
    if (error)
    {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:relativePath,RELATIVE_PATH_KEY,[error description],ERROR_KEY, nil];
        if (self.delegate)
        {
            [self.delegate handleResponseError:errorDict];
        }
    }
    else
    {
        NSDictionary *returnDict = [NSDictionary dictionaryWithObjectsAndKeys:relativePath,RELATIVE_PATH_KEY,_receiveData,RECEIVE_DATA_KEY, nil];
        if (self.delegate)
        {
            [self.delegate handleResponseData:returnDict];
        }
    }
}

@end
