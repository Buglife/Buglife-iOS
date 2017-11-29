//
//  LIFERecordingShrinker.m
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

#import "LIFERecordingShrinker.h"
#import "LIFEVideoAttachment.h"
#import "LIFEMacros.h"
#import "LIFEAVFoundation.h"

@interface LIFERecordingShrinker ()
@property (nullable) NSObject<LIFEAVAssetExportSession> *exportSession;
@end

@implementation LIFERecordingShrinker

- (instancetype)initWithRecording:(LIFEVideoAttachment *)recording {
    self = [super init];
    if (self != nil) {
        _recording = recording;
    }
    return self;
}

- (void)startShrinkOnQueue:(dispatch_queue_t)queue completionHandler:(LIFERecordingShrinkerCompletion)completionHandler {
    dispatch_async(queue, ^{
        [self shrinkWithCompletionHandler:completionHandler];
    });
}

- (void)startShrinkOnOperationQueue:(NSOperationQueue *)opq completionHandler:(LIFERecordingShrinkerCompletion)completionHandler {
    [opq addOperationWithBlock:^{
        [self shrinkWithCompletionHandler:completionHandler];
    }];
}

- (NSURL *)buglifeCachesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cachesDirectory = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *buglifeCachesDirectory = [cachesDirectory URLByAppendingPathComponent:@"com.buglife.buglife" isDirectory:YES];
    
    NSError *error;
    BOOL directoryCreated = [fileManager createDirectoryAtURL:buglifeCachesDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!directoryCreated) {
        LIFELogExtError(@"Buglife Error: Unable create directory for pending bug reports. Error details: %@", error);
        NSParameterAssert(NO);
        // Just return the app's caches directory if for some crazy reason there's an error here
        return cachesDirectory;
    }
    
    return buglifeCachesDirectory;
}

- (void)shrinkWithCompletionHandler:(LIFERecordingShrinkerCompletion)completionHandler {
    LIFELoadAVFoundation();
    
    Class AVURLAssetClass = NSClassFromString(@"AVURLAsset");
    Class AVAssetTrackClass = NSClassFromString(@"AVAssetTrack");
    Class AVMutableVideoCompositionClass = NSClassFromString(@"AVMutableVideoComposition");
    Class AVMutableVideoCompositionInstructionClass = NSClassFromString(@"AVMutableVideoCompositionInstruction");
    Class AVMutableVideoCompositionLayerInstructionClass = NSClassFromString(@"AVMutableVideoCompositionLayerInstruction");
    Class AVAssetExportSessionClass = NSClassFromString(@"AVAssetExportSession");
    
    if (!(AVURLAssetClass && AVAssetTrackClass && AVMutableVideoCompositionClass && AVMutableVideoCompositionInstructionClass && AVMutableVideoCompositionLayerInstructionClass && AVAssetExportSessionClass)) {
        LIFELogExtError(@"Buglife error: Internal error compressing video. Please report this! Debug information: %@ / %@ / %@ / %@ / %@ / %@", AVURLAssetClass, AVAssetTrackClass, AVMutableVideoCompositionClass, AVMutableVideoCompositionInstructionClass, AVMutableVideoCompositionLayerInstructionClass, AVAssetExportSessionClass);
        return;
    }
    
    NSURL *url = self.recording.url;
    NSObject<LIFEAVURLAsset> *urlAsset = [[AVURLAssetClass alloc] initWithURL:url options: nil];
    
    NSObject<LIFEAVAssetTrack> *videoTrack = [[urlAsset tracksWithMediaType:LIFEAVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoTrack.naturalSize;
    CGSize quarterSize = CGSizeMake(naturalSize.width/4.0, naturalSize.height/4.0);
    
    NSObject<LIFEAVMutableVideoComposition> *videoComposition = [AVMutableVideoCompositionClass videoComposition];
    videoComposition.renderSize = quarterSize;
    videoComposition.frameDuration = LIFECMTimeMake(1, videoTrack.nominalFrameRate);
    
    NSObject<LIFEAVMutableVideoCompositionInstruction> *instruction = [[AVMutableVideoCompositionInstructionClass alloc] init];
    instruction.timeRange = LIFECMTimeRangeMake(LIFECMTimeZero(), LIFECMTimePositiveInfinity());
    
    NSObject<LIFEAVMutableVideoCompositionLayerInstruction> *transform = [AVMutableVideoCompositionLayerInstructionClass videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(.25, .25);
    [transform setTransform:scaleTransform atTime:LIFECMTimeZero()];
    
    [instruction setLayerInstructions:(NSArray<LIFEAVVideoCompositionLayerInstruction> *)@[transform]];
    [videoComposition setInstructions:(NSArray<LIFEAVVideoCompositionInstruction> *)@[instruction]];
    
    NSObject<LIFEAVAssetExportSession> *exportSession = [[AVAssetExportSessionClass alloc] initWithAsset:urlAsset presetName:LIFEAVAssetExportPresetHighestQuality];
    self.exportSession = exportSession;
    NSURL *outputUrl = [[self buglifeCachesDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"shrunkrecording_%.0f.mp4", self.recording.creationDate.timeIntervalSince1970]];
    exportSession.outputURL = outputUrl;
    exportSession.outputFileType = LIFEAVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.fileLengthLimit = 3145728;
    exportSession.canPerformMultiplePassesOverSourceMediaData = YES;
    exportSession.videoComposition = videoComposition;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandler(outputUrl);
    }];
}

- (float)progress {
    return self.exportSession.progress;
}
@end
