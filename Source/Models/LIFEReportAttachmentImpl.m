//
//  LIFEAttachment.m
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

#import "LIFEReportAttachmentImpl.h"
#import "Buglife+Protected.h"
#import "LIFEMacros.h"
#import "NSMutableDictionary+LIFEAdditions.h"

static NSString * const kLogVersion = @"2.0";
static NSString * const kLogFilename = @"logs.json";
NSString * const LIFEScreenshotDefaultFilename = @"Screenshot.png";

@implementation LIFEReportAttachmentImpl

- (instancetype)initWithData:(NSData *)data uniformTypeIdentifier:(NSString *)uti filename:(NSString *)filename
{
    self = [super init];
    if (self) {
        _attachmentData = data;
        _uniformTypeIdentifier = uti;
        _filename = filename;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image filename:(NSString *)filename
{
    self = [super init];
    if (self) {
        _attachmentData = UIImagePNGRepresentation(image);
        _uniformTypeIdentifier = LIFEAttachmentTypeIdentifierImage;
        _filename = filename;
    }
    return self;
}

- (instancetype)initWithLogData:(NSData *)logData
{
    self = [self initWithData:logData uniformTypeIdentifier:LIFEAttachmentTypeIdentifierJSON filename:kLogFilename];

    if (self) {
        _logVersion = kLogVersion;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        for (NSString *key in [[self class] _objectPropertyKeys]) {
            id value = [coder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    for (NSString *key in [[self class] _objectPropertyKeys]) {
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
}

+ (NSArray<NSString *> *)_objectPropertyKeys
{
    return @[LIFE_STRING_FROM_SELECTOR_NAMED(attachmentData),
             LIFE_STRING_FROM_SELECTOR_NAMED(uniformTypeIdentifier),
             LIFE_STRING_FROM_SELECTOR_NAMED(filename),
             LIFE_STRING_FROM_SELECTOR_NAMED(logVersion)];
}

#pragma mark - Public methods

- (BOOL)isImageAttachment
{
    return (
        [self.uniformTypeIdentifier isEqual:LIFEAttachmentTypeIdentifierImage] ||
        [self.uniformTypeIdentifier isEqual:LIFEAttachmentTypeIdentifierPNG] ||
        [self.uniformTypeIdentifier isEqual:LIFEAttachmentTypeIdentifierJPEG]
    );
}

- (NSDictionary *)JSONDictionary
{
    NSMutableDictionary *attachmentDict = [[NSMutableDictionary alloc] init];
    
    [attachmentDict life_safeSetObject:self._base64attachmentData forKey:@"base64_attachment_data"];
    [attachmentDict life_safeSetObject:self.uniformTypeIdentifier forKey:@"uniform_type_identifier"];
    [attachmentDict life_safeSetObject:self.filename forKey:@"filename"];
    [attachmentDict life_safeSetObject:self.logVersion forKey:@"log_version"];
    
    return [NSDictionary dictionaryWithDictionary:attachmentDict];
}

- (NSUInteger)size
{
    return _attachmentData.length;
}

- (NSString *)_base64attachmentData
{
    return [self.attachmentData base64EncodedStringWithOptions:0];
}

#pragma mark - Debugging

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p (%@)>", NSStringFromClass([self class]), self, self.filename];
}

- (id)debugQuickLookObject
{
    if ([self isImageAttachment]) {
        return [UIImage imageWithData:self.attachmentData];
    } else {
        return nil;
    }
}

@end
