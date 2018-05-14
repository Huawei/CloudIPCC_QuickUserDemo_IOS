
#import <Foundation/Foundation.h>
#import "CCCommonDefine.h"
#import "CCLogger.h"
#import "CCUtil.h"


#define CCLogFormat @"%@:%@ line:%d | %s | "

#define logErr(fmt, ...)    [[CCLogger defaultLogger] log:LOG_ERROR format:(CCLogFormat fmt), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle] ,[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]

#define logWarn(fmt, ...)    [[CCLogger defaultLogger] log:LOG_WARNING format:(CCLogFormat fmt), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle] ,[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]

#define logInfo(fmt, ...)    [[CCLogger defaultLogger] log:LOG_INFO format:(CCLogFormat fmt),  [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle] ,[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]

#define logDbg(fmt, ...)    [[CCLogger defaultLogger] log:LOG_DEBUG format:(CCLogFormat fmt), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle] ,[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__]

/**
 *  OBSLogger is an utility class that handles logging to the console.
 *  You can specify the log level to control how verbose the output will be.
 */
@interface CCLogger : NSObject

/**
 *  The log level setting. The default is OBSLogLevelNone.
 */
@property (atomic, assign) CCLogLevel logLevel;

/**
 *  Returns the shared logger object.
 *
 *  @return The shared logger object.
 */
+ (instancetype)defaultLogger;

- (void)setLogPath:(NSString *)path;

/**
 *  Prints out the formatted logs to the console.
 *
 *  @param logLevel The level of this log.
 *  @param fmt      The formatted string to log.
 */
- (void)log:(CCLogLevel)logLevel
     format:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end


