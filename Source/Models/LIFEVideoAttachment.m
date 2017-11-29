//
//  LIFEScreenRecording.m
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

#import "LIFEVideoAttachment.h"
#import "LIFEMacros.h"
#import <UIKit/UIKit.h>
#import "LIFEAVFoundation.h"

@interface LIFEVideoAttachment ()

@property (nonnull) NSURL *url;
@property (nonnull) NSString *uniformTypeIdentifier;
@property (nonnull) NSString *filename;
@property (nonnull) NSDate *creationDate;

@end

@implementation LIFEVideoAttachment

- (instancetype)initWithFileURL:(NSURL *)url uniformTypeIdentifier:(NSString *)uniformTypeIdentifier filename:(NSString *)filename isProcessing:(BOOL)processing;
{
    self = [super init];
    if (self) {
        _url = url;
        _uniformTypeIdentifier = uniformTypeIdentifier;
        _filename = filename;
        _creationDate = [NSDate date];
        _processing = processing;
    }
    return self;
}

- (UIImage *)getThumbnail
{
    if (self.isProcessing) {
        return nil;
    }
    
    LIFELoadAVFoundation();
    
    Class AVAssetClass = NSClassFromString(@"AVAsset");
    Class AVAssetImageGeneratorClass = NSClassFromString(@"AVAssetImageGenerator");
    
    if (!(AVAssetClass && AVAssetImageGeneratorClass)) {
        LIFELogExtError(@"Buglife error: Internal error compressing video. Please report this! Debug information: %@ / %@", AVAssetClass, AVAssetImageGeneratorClass);
        return nil;
    }
    
    NSObject<LIFEAVAsset> *asset = [AVAssetClass assetWithURL:self.url];
    NSObject<LIFEAVAssetImageGenerator> *imageGenerator = [AVAssetImageGeneratorClass assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    let time = LIFECMTimeMake(1, 30);
    NSError *error = nil;
    CGImageRef image = [imageGenerator copyCGImageAtTime:time actualTime:nil error:&error];
    
    if (image == nil) {
        LIFELogError(@"Unable to generate thumbnail from video attachment: %@", error);
        return  nil;
    } else {
        return [UIImage imageWithCGImage:image];
    }
}

@end
