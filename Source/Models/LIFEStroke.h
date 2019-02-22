//
//  LIFEStroke.h
//  Copyright (C) 2019 Buglife, Inc.
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LIFEStrokePhase) {
    LIFEStrokePhaseBegan,
    LIFEStrokePhaseChanged,
    LIFEStrokePhaseEnded,
    LIFEStrokePhaseCanceled
};

@interface LIFEStrokeSample : NSObject <NSCopying>
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) CGPoint location;
@property (nonatomic, assign) CGFloat force;

//Pencil only properties
@property (nonatomic, assign) UITouchProperties estimatedTouchProperties; // not sure these are right
@property (nonatomic, assign) UITouchProperties estimatedTouchPropertiesExpectingUpdates;
@property (nonatomic, assign) CGFloat altitude;
@property (nonatomic, assign) CGFloat azimuth;

@property (nonatomic, readonly) CGVector azimuthUnitVector;
- (instancetype)initWithTimestamp:(NSDate *)timestamp location:(CGPoint)location coalesced:(BOOL)coalesced predicted:(BOOL)predicted force:(CGFloat)force azimuth:(CGFloat)azimuth altitude:(CGFloat)altitude;
@property (nonatomic, readonly) CGFloat perpendicularForce;
@property (nonatomic, readonly) BOOL coalesced;
@property (nonatomic, readonly) BOOL predicted;
@end

typedef NS_ENUM(NSUInteger, LIFEStrokeState) {
    LIFEStrokeStateActive,
    LIFEStrokeStateDone,
    LIFEStrokeStateCanceled,
};

typedef void (^LIFEStrokeReceivedAllNeededUpdatesBlock)(void);

@interface LIFEStroke : NSObject
@property (nonatomic, strong) NSMutableArray<LIFEStrokeSample *> *samples;
@property (nonatomic, strong) NSMutableArray<LIFEStrokeSample *> *predictedSamples;
@property (nonatomic, nullable, strong) NSMutableArray<LIFEStrokeSample *> *previousPredictedSamples;
@property (nonatomic, assign) LIFEStrokeState state;
@property (nonatomic, strong) NSMutableIndexSet *sampleIndiciesExpectingUpdates;
@property (nonatomic, assign) BOOL expectsAltitudeAzimutBackfill;
@property (nonatomic, assign) NSInteger hasUpdatesFromStartTo;
@property (nonatomic, assign) NSInteger hasUpdatesAtEndFrom;
@property (nonatomic, nullable) LIFEStrokeReceivedAllNeededUpdatesBlock receivedAllNeededUpdates;
- (NSInteger)addSample:(LIFEStrokeSample *)sample;
- (void)updateSample:(LIFEStrokeSample *)sample atIndex:(NSInteger)index;
- (void)addPredictedSample:(LIFEStrokeSample *)sample;
- (void)clearUpdateInfo;
- (NSArray<NSValue *> *)updatedRanges;
@end

@interface LIFEStrokeSegment : NSObject
@property (nonatomic, nullable) LIFEStrokeSample *sampleBefore;
@property (nonatomic) LIFEStrokeSample *fromSample;
@property (nonatomic) LIFEStrokeSample *toSample;
@property (nonatomic, nullable) LIFEStrokeSample *sampleAfter;
@property (nonatomic, assign) NSInteger fromSampleIndex;
- (CGVector)segmentUnitNormal;
- (CGVector)fromSampleUnitNormal;
- (CGVector)previousSegmentStrokeVector;
- (CGVector)segmentStrokeVector;
- (CGVector)nextSegmentStrokeVector;
- (instancetype)initWithStrokeSample:(LIFEStrokeSample *)sample;
- (BOOL)advanceWithSample:(LIFEStrokeSample *)incomingSample;
@end

NS_ASSUME_NONNULL_END
