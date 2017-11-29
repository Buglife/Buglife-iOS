//
//  LIFEAVFoundation.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LIFEMacros.h"

NS_ASSUME_NONNULL_BEGIN

void LIFELoadAVFoundation(void);

CMTime LIFECMTimeZero(void);
CMTime LIFECMTimePositiveInfinity(void);
CMTimeRange LIFECMTimeRangeZero(void);
CMTime LIFECMTimeMake(int64_t value, int32_t timescale);
CMTimeRange LIFECMTimeRangeMake(CMTime start, CMTime duration);

static _Nonnull let LIFEAVMediaTypeVideo = @"vide";
static _Nonnull let LIFEAVAssetExportPresetHighestQuality = @"AVAssetExportPresetHighestQuality";
static _Nonnull let LIFEAVFileTypeMPEG4 = @"public.mpeg-4";

@protocol LIFEAVAssetTrack <NSObject>
@property (nonatomic, readonly) CGSize naturalSize;
@property (nonatomic, readonly) float nominalFrameRate;
@end

@protocol LIFEAVAsset <NSObject>
+ (instancetype)assetWithURL:(NSURL *)URL;
@end

@protocol LIFEAVURLAsset <LIFEAVAsset>
- (instancetype)initWithURL:(NSURL *)URL options:(nullable NSDictionary<NSString *, id> *)options;
- (NSArray<LIFEAVAssetTrack> *)tracksWithMediaType:(NSString *)mediaType;
- (NSURL *)URL;
@end

@protocol LIFEAVVideoComposition <NSObject>
@end

@protocol LIFEAVAssetExportSession <NSObject>
- (nullable instancetype)initWithAsset:(id<LIFEAVAsset>)asset presetName:(NSString *)presetName;
@property (nonatomic, copy, nullable) NSURL *outputURL;
@property (nonatomic, copy, nullable) NSString *outputFileType;
@property (nonatomic) BOOL shouldOptimizeForNetworkUse;
@property (nonatomic) long long fileLengthLimit;
@property (nonatomic) BOOL canPerformMultiplePassesOverSourceMediaData;
@property (nonatomic, copy, nullable) id<LIFEAVVideoComposition> videoComposition;
@property (nonatomic, readonly) float progress;
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(void))handler;
@end

@protocol LIFEAVVideoCompositionInstruction <NSObject>
@end

@protocol LIFEAVMutableVideoComposition <LIFEAVVideoComposition>
+ (instancetype)videoComposition;
@property (nonatomic) CGSize renderSize;
@property (nonatomic) CMTime frameDuration;
@property (nonatomic, copy) NSArray<LIFEAVVideoCompositionInstruction> *instructions;
@end

@protocol LIFEAVVideoCompositionLayerInstruction <LIFEAVVideoCompositionInstruction>
@end

@protocol LIFEAVMutableVideoCompositionInstruction <NSObject>
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, copy) NSArray<LIFEAVVideoCompositionLayerInstruction> *layerInstructions;
@end

@protocol LIFEAVMutableVideoCompositionLayerInstruction <LIFEAVVideoCompositionLayerInstruction>
+ (instancetype)videoCompositionLayerInstructionWithAssetTrack:(id<LIFEAVAssetTrack>)track;
- (void)setTransform:(CGAffineTransform)transform atTime:(CMTime)time;
@end

@protocol LIFEAVAssetImageGenerator <NSObject>
+ (instancetype)assetImageGeneratorWithAsset:(id<LIFEAVAsset>)asset;
@property (nonatomic) BOOL appliesPreferredTrackTransform;
- (nullable CGImageRef)copyCGImageAtTime:(CMTime)requestedTime actualTime:(nullable CMTime *)actualTime error:(NSError * _Nullable * _Nullable)outError CF_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
