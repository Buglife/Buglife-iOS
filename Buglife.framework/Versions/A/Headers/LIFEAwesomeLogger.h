//
//  LIFEAwesomeLogger.h
//  Buglife
//
//  Copyright © 2017 Buglife, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LIFE_Log(isAsync, aType, aFunct, frmt, ...)         \
    do {                                                    \
        [[LIFEAwesomeLogger sharedLogger]                   \
            log:isAsync                                     \
            type:aType                                      \
            file:__FILE__                                   \
            function:aFunct                                 \
            line:__LINE__                                   \
            format:(frmt), ## __VA_ARGS__];                 \
    } while (0)

typedef NS_ENUM(NSUInteger, LIFEAwesomeLogType){
    LIFEAwesomeLogTypeError    = (1 << 0),
    LIFEAwesomeLogTypeInfo     = (1 << 2),
    LIFEAwesomeLogTypeDebug    = (1 << 3)
};

#define LIFELogError(frmt, ...)     \
    LIFE_Log(NO, LIFEAwesomeLogTypeError, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define LIFELogInfo(frmt, ...)     \
    LIFE_Log(YES, LIFEAwesomeLogTypeInfo, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define LIFELogDebug(frmt, ...)     \
    LIFE_Log(YES, LIFEAwesomeLogTypeDebug, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#ifdef LIFE_REPLACE_NSLOG_WITH_AWESOMELOG
    #define NSLog(frmt, ...) LIFELogDebug(frmt, ##__VA_ARGS__)
#endif

/**
 *  Refer to the AwesomeLogs usage guide at https://www.buglife.com/docs/ios/logging.html
 */
@interface LIFEAwesomeLogger : NSObject

+ (nonnull instancetype)sharedLogger;

/**
 A boolean value that determines whether AwesomeLogs outputs to the Xcode debugger console.
 Setting the value of this property to `false` will disable console logging from AwesomeLogs,
 however AwesomeLogs will still be included in submitted bug reports.
 
 This property returns `true` by default.
 */
@property (nonatomic, getter=isConsoleLoggingEnabled) BOOL consoleLoggingEnabled;

- (void)log:(BOOL)asynchronous
       type:(LIFEAwesomeLogType)type
       file:(nonnull const char *)file
   function:(nonnull const char *)function
       line:(NSUInteger)line
     format:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(6,7);

- (void)log:(BOOL)asynchronous
       type:(LIFEAwesomeLogType)type
       file:(nonnull NSString *)file
   function:(nonnull NSString *)function
       line:(NSUInteger)line
    message:(nonnull NSString *)message;

@end
