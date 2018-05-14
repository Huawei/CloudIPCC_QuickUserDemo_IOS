

#include "CCLogger.h"
#import "CCConstantInfo.h"


static char kLogFilePath[1024] = {'\0'};

@interface CCLogger()
{
    NSString *_logPath;
}

@end

@implementation CCLogger

- (instancetype)init
{
    if (self = [super init])
    {
        _logLevel = LOG_NONE;
        _logPath = nil;
    }
    
    return self;
}

+ (instancetype)defaultLogger
{
    static CCLogger *_defaultLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultLogger = [CCLogger new];
        _defaultLogger.logLevel = LOG_INFO; //set default logLevel
    });
    
    return _defaultLogger;
}

- (void)setLogPath:(NSString *)path
{

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _logPath = (path== nil) ? [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TUP_LOG"]:path;
    NSString* logFilePath = [_logPath stringByAppendingPathComponent:@"eSDK-CC-API-iOS-ObjC.log"] ;
    [CCConstantInfo shareInstance].logPath = _logPath;
    BOOL success =NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath] == YES)
    {
        success =YES;
        NSData *contentData = [[NSFileManager defaultManager] contentsAtPath:logFilePath];
        if ([contentData length]>1024*1024*10)
        {
            [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:nil];
            NSString *startStr = @"===========CC Log start==============\r\n";
            success = [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[startStr dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
        
    }
    else
    {
        NSString *recreateStr = @"===========CC Log start==============\r\n";
        success = [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[recreateStr dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    if (success)
    {
        if (strlen([logFilePath UTF8String]) >= 1024)
        {
            NSLog(@"error logFilePath length");
            return;
        }
        strlcpy(kLogFilePath, [logFilePath UTF8String],sizeof(kLogFilePath));
    }
    
}


- (void)log:(CCLogLevel)logLevel format:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3)
{
    if (self.logLevel < logLevel)
    {
        return;
    }
    
    va_list args;
    va_start(args, fmt);
    NSString *printfMsg = [[NSString alloc] initWithFormat:@"CCiOSSDK [%@] %@", [self logLevelLabel:logLevel], [[NSString alloc] initWithFormat:fmt arguments:args]];
    va_end(args);
    
    [self setLogPath:_logPath];

    int fd = open(kLogFilePath, O_WRONLY|O_APPEND);
    const char *message = [printfMsg UTF8String];
    
    write(fd,"\r\n",2);
    write(fd, message, strlen(message));
    close(fd);
}

- (NSString *)logLevelLabel:(CCLogLevel)logLevel
{
    switch (logLevel)
    {
        case LOG_ERROR:
            return @"Error";
            
        case LOG_WARNING:
            return @"Warn";
            
        case LOG_INFO:
            return @"Info";
            
        case LOG_DEBUG:
            return @"Debug";
            
        case LOG_NONE:
        default:
            return @"?";
    }
}

@end
