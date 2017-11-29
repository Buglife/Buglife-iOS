//
//  LIFELog.h
//  Copyright (C) 2017 Buglife, Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//       http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2016, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.


#import <Foundation/Foundation.h>

/**
 *  Flags accompany each log. They are used together with levels to filter out logs.
 */
typedef NS_OPTIONS(NSUInteger, LIFELogFlag){
    /**
     *  0...00001 DDLogFlagError
     */
    LIFELogFlagError      = (1 << 0),
    
    /**
     *  0...00010 DDLogFlagWarning
     */
    LIFELogFlagWarning    = (1 << 1),
    
    /**
     *  0...00100 DDLogFlagInfo
     */
    LIFELogFlagInfo       = (1 << 2),
    
    /**
     *  0...01000 DDLogFlagDebug
     */
    LIFELogFlagDebug      = (1 << 3),
    
    /**
     *  0...10000 DDLogFlagVerbose
     */
    LIFELogFlagVerbose    = (1 << 4)
};

/**
 *  Log levels are used to filter out logs. Used together with flags.
 */
typedef NS_ENUM(NSUInteger, LIFELogLevel){
    /**
     *  No logs
     */
    LIFELogLevelOff       = 0,
    
    /**
     *  Error logs only
     */
    LIFELogLevelError     = (LIFELogFlagError),
    
    /**
     *  Error and warning logs
     */
    LIFELogLevelWarning   = (LIFELogLevelError   | LIFELogFlagWarning),
    
    /**
     *  Error, warning and info logs
     */
    LIFELogLevelInfo      = (LIFELogLevelWarning | LIFELogFlagInfo),
    
    /**
     *  Error, warning, info and debug logs
     */
    LIFELogLevelDebug     = (LIFELogLevelInfo    | LIFELogFlagDebug),
    
    /**
     *  Error, warning, info, debug and verbose logs
     */
    LIFELogLevelVerbose   = (LIFELogLevelDebug   | LIFELogFlagVerbose),
    
    /**
     *  All logs (1...11111)
     */
    LIFELogLevelAll       = NSUIntegerMax
};


/**
 *  Log message options, allow copying certain log elements
 */
typedef NS_OPTIONS(NSInteger, LIFELogMessageOptions){
    /**
     *  Use this to use a copy of the file path
     */
    LIFELogMessageCopyFile     = 1 << 0,
    /**
     *  Use this to use a copy of the function name
     */
    LIFELogMessageCopyFunction = 1 << 1
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class LIFELogMessage;
@protocol LIFELogger;

/**
 *  The main class, exposes all logging mechanisms, loggers, ...
 *  For most of the users, this class is hidden behind the logging functions like `DDLogInfo`
 */
@interface LIFELogImpl : NSObject

/**
 * Provides access to the underlying logging queue.
 * This may be helpful to Logger classes for things like thread synchronization.
 **/
+ (dispatch_queue_t)loggingQueue;

/**
 * Logging Primitive.
 *
 * This method is used by the macros or logging functions.
 * It is suggested you stick with the macros as they're easier to use.
 *
 *  @param asynchronous YES if the logging is done async, NO if you want to force sync
 *  @param level        the log level
 *  @param flag         the log flag
 *  @param context      the context (if any is defined)
 *  @param file         the current file
 *  @param function     the current function
 *  @param line         the current code line
 *  @param tag          potential tag
 *  @param format       the log format
 */
+ (void)log:(BOOL)asynchronous
      level:(LIFELogLevel)level
       flag:(LIFELogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(9,10);

/**
 * Logging Primitive.
 *
 * This method can be used if you have a prepared va_list.
 * Similar to `log:level:flag:context:file:function:line:tag:format:...`
 *
 *  @param asynchronous YES if the logging is done async, NO if you want to force sync
 *  @param level        the log level
 *  @param flag         the log flag
 *  @param context      the context (if any is defined)
 *  @param file         the current file
 *  @param function     the current function
 *  @param line         the current code line
 *  @param tag          potential tag
 *  @param format       the log format
 *  @param argList      the arguments list as a va_list
 */
+ (void)log:(BOOL)asynchronous
      level:(LIFELogLevel)level
       flag:(LIFELogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format
       args:(va_list)argList;

/**
 *  Logging Primitive.
 *
 *  @param asynchronous YES if the logging is done async, NO if you want to force sync
 *  @param message      the message
 *  @param level        the log level
 *  @param flag         the log flag
 *  @param context      the context (if any is defined)
 *  @param file         the current file
 *  @param function     the current function
 *  @param line         the current code line
 *  @param tag          potential tag
 */
+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
      level:(LIFELogLevel)level
       flag:(LIFELogFlag)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag;

/**
 * Logging Primitive.
 *
 * This method can be used if you manualy prepared DDLogMessage.
 *
 *  @param asynchronous YES if the logging is done async, NO if you want to force sync
 *  @param logMessage   the log message stored in a `DDLogMessage` model object
 */
+ (void)log:(BOOL)asynchronous
    message:(LIFELogMessage *)logMessage;

/**
 * Since logging can be asynchronous, there may be times when you want to flush the logs.
 * The framework invokes this automatically when the application quits.
 **/
+ (void)flushLog;

/**
 * Loggers
 *
 * In order for your log statements to go somewhere, you should create and add a logger.
 *
 * You can add multiple loggers in order to direct your log statements to multiple places.
 * And each logger can be configured separately.
 * So you could have, for example, verbose logging to the console, but a concise log file with only warnings & errors.
 **/

/**
 * Adds the logger to the system.
 *
 * This is equivalent to invoking `[DDLog addLogger:logger withLogLevel:DDLogLevelAll]`.
 **/
+ (void)addLogger:(id <LIFELogger>)logger;

/**
 * Adds the logger to the system.
 *
 * The level that you provide here is a preemptive filter (for performance).
 * That is, the level specified here will be used to filter out logMessages so that
 * the logger is never even invoked for the messages.
 *
 * More information:
 * When you issue a log statement, the logging framework iterates over each logger,
 * and checks to see if it should forward the logMessage to the logger.
 * This check is done using the level parameter passed to this method.
 *
 * For example:
 *
 * `[DDLog addLogger:consoleLogger withLogLevel:DDLogLevelVerbose];`
 * `[DDLog addLogger:fileLogger    withLogLevel:DDLogLevelWarning];`
 *
 * `DDLogError(@"oh no");` => gets forwarded to consoleLogger & fileLogger
 * `DDLogInfo(@"hi");`     => gets forwarded to consoleLogger only
 *
 * It is important to remember that Lumberjack uses a BITMASK.
 * Many developers & third party frameworks may define extra log levels & flags.
 * For example:
 *
 * `#define SOME_FRAMEWORK_LOG_FLAG_TRACE (1 << 6) // 0...1000000`
 *
 * So if you specify `DDLogLevelVerbose` to this method, you won't see the framework's trace messages.
 *
 * `(SOME_FRAMEWORK_LOG_FLAG_TRACE & DDLogLevelVerbose) => (01000000 & 00011111) => NO`
 *
 * Consider passing `DDLogLevelAll` to this method, which has all bits set.
 * You can also use the exclusive-or bitwise operator to get a bitmask that has all flags set,
 * except the ones you explicitly don't want. For example, if you wanted everything except verbose & debug:
 *
 * `((DDLogLevelAll ^ DDLogLevelVerbose) | DDLogLevelInfo)`
 **/
+ (void)addLogger:(id <LIFELogger>)logger withLevel:(LIFELogLevel)level;

/**
 *  Remove the logger from the system
 */
+ (void)removeLogger:(id <LIFELogger>)logger;

/**
 *  Remove all the current loggers
 */
+ (void)removeAllLoggers;

/**
 *  Return all the current loggers
 */
+ (NSArray *)allLoggers;

/**
 * Registered Dynamic Logging
 *
 * These methods allow you to obtain a list of classes that are using registered dynamic logging,
 * and also provides methods to get and set their log level during run time.
 **/

/**
 *  Returns an array with the classes that are using registered dynamic logging
 */
+ (NSArray *)registeredClasses;

/**
 *  Returns an array with the classes names that are using registered dynamic logging
 */
+ (NSArray *)registeredClassNames;

/**
 *  Returns the current log level for a certain class
 *
 *  @param aClass `Class` param
 */
+ (LIFELogLevel)levelForClass:(Class)aClass;

/**
 *  Returns the current log level for a certain class
 *
 *  @param aClassName string param
 */
+ (LIFELogLevel)levelForClassWithName:(NSString *)aClassName;

/**
 *  Set the log level for a certain class
 *
 *  @param level  the new level
 *  @param aClass `Class` param
 */
+ (void)setLevel:(LIFELogLevel)level forClass:(Class)aClass;

/**
 *  Set the log level for a certain class
 *
 *  @param level      the new level
 *  @param aClassName string param
 */
+ (void)setLevel:(LIFELogLevel)level forClassWithName:(NSString *)aClassName;

@end

/**
 * The `DDLogMessage` class encapsulates information about the log message.
 * If you write custom loggers or formatters, you will be dealing with objects of this class.
 **/
@interface LIFELogMessage : NSObject <NSCopying>
{
    // Direct accessors to be used only for performance
@public
    NSString *_message;
    LIFELogLevel _level;
    LIFELogFlag _flag;
    NSInteger _context;
    NSString *_file;
    NSString *_fileName;
    NSString *_function;
    NSUInteger _line;
    id _tag;
    LIFELogMessageOptions _options;
    NSDate *_timestamp;
    NSString *_threadID;
    NSString *_threadName;
    NSString *_queueLabel;
}

/**
 *  Default `init` is not available
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Standard init method for a log message object.
 * Used by the logging primitives. (And the macros use the logging primitives.)
 *
 * If you find need to manually create logMessage objects, there is one thing you should be aware of:
 *
 * If no flags are passed, the method expects the file and function parameters to be string literals.
 * That is, it expects the given strings to exist for the duration of the object's lifetime,
 * and it expects the given strings to be immutable.
 * In other words, it does not copy these strings, it simply points to them.
 * This is due to the fact that __FILE__ and __FUNCTION__ are usually used to specify these parameters,
 * so it makes sense to optimize and skip the unnecessary allocations.
 * However, if you need them to be copied you may use the options parameter to specify this.
 *
 *  @param message   the message
 *  @param level     the log level
 *  @param flag      the log flag
 *  @param context   the context (if any is defined)
 *  @param file      the current file
 *  @param function  the current function
 *  @param line      the current code line
 *  @param tag       potential tag
 *  @param options   a bitmask which supports DDLogMessageCopyFile and DDLogMessageCopyFunction.
 *  @param timestamp the log timestamp
 *
 *  @return a new instance of a log message model object
 */
- (instancetype)initWithMessage:(NSString *)message
                          level:(LIFELogLevel)level
                           flag:(LIFELogFlag)flag
                        context:(NSInteger)context
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line
                            tag:(id)tag
                        options:(LIFELogMessageOptions)options
                      timestamp:(NSDate *)timestamp NS_DESIGNATED_INITIALIZER;

/**
 * Read-only properties
 **/

/**
 *  The log message
 */
@property (readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) LIFELogLevel level;
@property (readonly, nonatomic) LIFELogFlag flag;
@property (readonly, nonatomic) NSInteger context;
@property (readonly, nonatomic) NSString *file;
@property (readonly, nonatomic) NSString *fileName;
@property (readonly, nonatomic) NSString *function;
@property (readonly, nonatomic) NSUInteger line;
@property (readonly, nonatomic) id tag;
@property (readonly, nonatomic) LIFELogMessageOptions options;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSString *threadID; // ID as it appears in NSLog calculated from the machThreadID
@property (readonly, nonatomic) NSString *threadName;
@property (readonly, nonatomic) NSString *queueLabel;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol LIFELogger;

/**
 *  This protocol describes the behavior of a log formatter
 */
@protocol LIFELogFormatter <NSObject>
@required

/**
 * Formatters may optionally be added to any logger.
 * This allows for increased flexibility in the logging environment.
 * For example, log messages for log files may be formatted differently than log messages for the console.
 *
 * For more information about formatters, see the "Custom Formatters" page:
 * Documentation/CustomFormatters.md
 *
 * The formatter may also optionally filter the log message by returning nil,
 * in which case the logger will not log the message.
 **/
- (NSString *)formatLogMessage:(LIFELogMessage *)logMessage;

@optional

/**
 * A single formatter instance can be added to multiple loggers.
 * These methods provides hooks to notify the formatter of when it's added/removed.
 *
 * This is primarily for thread-safety.
 * If a formatter is explicitly not thread-safe, it may wish to throw an exception if added to multiple loggers.
 * Or if a formatter has potentially thread-unsafe code (e.g. NSDateFormatter),
 * it could possibly use these hooks to switch to thread-safe versions of the code.
 **/
- (void)didAddToLogger:(id <LIFELogger>)logger;

/**
 *  See the above description for `didAddToLogger:`
 */
- (void)willRemoveFromLogger:(id <LIFELogger>)logger;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  This protocol describes a dynamic logging component
 */
@protocol LIFERegisteredDynamicLogging

/**
 * Implement these methods to allow a file's log level to be managed from a central location.
 *
 * This is useful if you'd like to be able to change log levels for various parts
 * of your code from within the running application.
 *
 * Imagine pulling up the settings for your application,
 * and being able to configure the logging level on a per file basis.
 *
 * The implementation can be very straight-forward:
 *
 * ```
 * + (int)ddLogLevel
 * {
 *     return ddLogLevel;
 * }
 *
 * + (void)ddSetLogLevel:(DDLogLevel)level
 * {
 *     ddLogLevel = level;
 * }
 * ```
 **/
+ (LIFELogLevel)lifeLogLevel;

/**
 *  See the above description for `ddLogLevel`
 */
+ (void)lifeSetLogLevel:(LIFELogLevel)level;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  This protocol describes a basic logger behavior.
 *  Basically, it can log messages, store a logFormatter plus a bunch of optional behaviors.
 *  (i.e. flush, get its loggerQueue, get its name, ...
 */
@protocol LIFELogger <NSObject>

/**
 *  The log message method
 *
 *  @param logMessage the message (model)
 */
- (void)logMessage:(LIFELogMessage *)logMessage;

/**
 * Formatters may optionally be added to any logger.
 *
 * If no formatter is set, the logger simply logs the message as it is given in logMessage,
 * or it may use its own built in formatting style.
 **/
@property (nonatomic, strong) id <LIFELogFormatter> logFormatter;

@optional

/**
 * Since logging is asynchronous, adding and removing loggers is also asynchronous.
 * In other words, the loggers are added and removed at appropriate times with regards to log messages.
 *
 * - Loggers will not receive log messages that were executed prior to when they were added.
 * - Loggers will not receive log messages that were executed after they were removed.
 *
 * These methods are executed in the logging thread/queue.
 * This is the same thread/queue that will execute every logMessage: invocation.
 * Loggers may use these methods for thread synchronization or other setup/teardown tasks.
 **/
- (void)didAddLogger;

/**
 *  See the above description for `didAddLoger`
 */
- (void)willRemoveLogger;

/**
 * Some loggers may buffer IO for optimization purposes.
 * For example, a database logger may only save occasionaly as the disk IO is slow.
 * In such loggers, this method should be implemented to flush any pending IO.
 *
 * This allows invocations of DDLog's flushLog method to be propogated to loggers that need it.
 *
 * Note that DDLog's flushLog method is invoked automatically when the application quits,
 * and it may be also invoked manually by the developer prior to application crashes, or other such reasons.
 **/
- (void)flush;

/**
 * Each logger is executed concurrently with respect to the other loggers.
 * Thus, a dedicated dispatch queue is used for each logger.
 * Logger implementations may optionally choose to provide their own dispatch queue.
 **/
@property (nonatomic, readonly) dispatch_queue_t loggerQueue;

/**
 * If the logger implementation does not choose to provide its own queue,
 * one will automatically be created for it.
 * The created queue will receive its name from this method.
 * This may be helpful for debugging or profiling reasons.
 **/
@property (nonatomic, readonly) NSString *loggerName;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * The `DDLogger` protocol specifies that an optional formatter can be added to a logger.
 * Most (but not all) loggers will want to support formatters.
 *
 * However, writting getters and setters in a thread safe manner,
 * while still maintaining maximum speed for the logging process, is a difficult task.
 *
 * To do it right, the implementation of the getter/setter has strict requiremenets:
 * - Must NOT require the `logMessage:` method to acquire a lock.
 * - Must NOT require the `logMessage:` method to access an atomic property (also a lock of sorts).
 *
 * To simplify things, an abstract logger is provided that implements the getter and setter.
 *
 * Logger implementations may simply extend this class,
 * and they can ACCESS THE FORMATTER VARIABLE DIRECTLY from within their `logMessage:` method!
 **/
@interface LIFEAbstractLogger : NSObject <LIFELogger>
{
    // Direct accessors to be used only for performance
@public
    id <LIFELogFormatter> _logFormatter;
    dispatch_queue_t _loggerQueue;
}

@property (nonatomic, strong) id <LIFELogFormatter> logFormatter;
@property (nonatomic) dispatch_queue_t loggerQueue;

// For thread-safety assertions

/**
 *  Return YES if the current logger uses a global queue for logging
 */
@property (nonatomic, readonly, getter=isOnGlobalLoggingQueue)  BOOL onGlobalLoggingQueue;

/**
 *  Return YES if the current logger uses the internal designated queue for logging
 */
@property (nonatomic, readonly, getter=isOnInternalLoggerQueue) BOOL onInternalLoggerQueue;

@end
