//
//  LIFEStroke.m
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

#import "LIFEStroke.h"

@implementation LIFEStrokeSample
- (instancetype)initWithTimestamp:(NSDate *)timestamp location:(CGPoint)location coalesced:(BOOL)coalesced predicted:(BOOL)predicted force:(CGFloat)force azimuth:(CGFloat)azimuth altitude:(CGFloat)altitude {
    self = [super init];
    if (self != nil) {
        _timestamp = timestamp;
        _location = location;
        _coalesced = coalesced;
        _predicted = predicted;
        _force = force != 0 ? force : 1.0;
        _azimuth = azimuth;
        _altitude = altitude;
    }
    return self;
}

- (CGVector)azimuthUnitVector {
    CGVector vector = CGVectorMake(1.0, 0.0);
    CGPoint point = CGPointApplyAffineTransform(CGPointMake(vector.dx, vector.dy), CGAffineTransformMakeRotation(self.azimuth));
    vector = CGVectorMake(point.x, point.y);
    return vector;
}
- (CGFloat)perpendicularForce {
    if (isnan(self.altitude)) {
        return self.force / sin(self.altitude);
    }
    return self.force;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    return [[LIFEStrokeSample alloc] initWithTimestamp:self.timestamp.copy location:self.location coalesced:self.coalesced predicted:self.predicted force:self.force azimuth:self.azimuth altitude:self.altitude];
}
@end

@implementation LIFEStroke
- (id)init {
    self = [super init];
    if (self != nil) {
        _samples = [NSMutableArray array];
        _predictedSamples = [NSMutableArray array];
        _state = LIFEStrokeStateActive;
        _sampleIndiciesExpectingUpdates = [NSMutableIndexSet indexSet];
        _expectsAltitudeAzimutBackfill = NO;
        _hasUpdatesFromStartTo = NSNotFound;
        _hasUpdatesAtEndFrom = NSNotFound;
    }
    return self;
}

- (NSInteger)addSample:(LIFEStrokeSample *)sample {
    NSUInteger resultIndex = self.samples.count;
    if (self.hasUpdatesAtEndFrom != NSNotFound) {
        self.hasUpdatesAtEndFrom = resultIndex;
    }
    [self.samples addObject:sample];
    if (self.previousPredictedSamples == nil) {
        self.previousPredictedSamples = self.predictedSamples;
    }
    if (sample.estimatedTouchPropertiesExpectingUpdates != 0) {
        [self.sampleIndiciesExpectingUpdates addIndex:resultIndex];
    }
    [self.predictedSamples removeAllObjects];
    return resultIndex;
}

- (void)updateSample:(LIFEStrokeSample *)sample atIndex:(NSInteger)index {
    if (index == 0) {
        self.hasUpdatesFromStartTo = 0;
    }
    else if (self.hasUpdatesFromStartTo != NSNotFound && index == self.hasUpdatesFromStartTo + 1) {
        self.hasUpdatesFromStartTo = index;
    }
    else if (self.hasUpdatesAtEndFrom == NSNotFound || self.hasUpdatesAtEndFrom > index) {
        self.hasUpdatesAtEndFrom = index;
    }
    self.samples[index] = sample;
    [self.sampleIndiciesExpectingUpdates removeIndex:index];
    
    if (self.sampleIndiciesExpectingUpdates.count == 0) {
        if (self.receivedAllNeededUpdates != nil) {
            LIFEStrokeReceivedAllNeededUpdatesBlock block = self.receivedAllNeededUpdates;
            self.receivedAllNeededUpdates = nil;
            block();
        }
    }
}

- (void)addPredictedSample:(LIFEStrokeSample *)sample {
    [self.predictedSamples addObject:sample];
}

- (void)clearUpdateInfo {
    self.hasUpdatesFromStartTo = NSNotFound;
    self.hasUpdatesAtEndFrom = NSNotFound;
    self.previousPredictedSamples = nil;
}

- (NSArray<NSValue *> *)updatedRanges {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:2];
    if (self.hasUpdatesFromStartTo != NSNotFound) {
        [ret addObject:[NSValue valueWithRange:NSMakeRange(0, self.hasUpdatesFromStartTo)]];
    }
    if (self.hasUpdatesAtEndFrom != NSNotFound) {
        [ret addObject:[NSValue valueWithRange:NSMakeRange(self.hasUpdatesAtEndFrom, self.samples.count -1)]];
    }
    return [NSArray arrayWithArray:ret];
}
@end

static CGFloat CGVectorGetQuadrance(CGVector vector) {
    return vector.dx * vector.dx + vector.dy * vector.dy;
}

static CGVector CGVectorGetNormal(CGVector vector) {
    if (!((vector.dx == 0.0 || vector.dx == -0.0) && (vector.dy == 0.0 || vector.dy == -0.0))) {
        return CGVectorMake(-vector.dy, vector.dx);
    }
    return CGVectorMake(0, 0);
}

static CGVector CGVectorGetNormalized(CGVector vector) {
    CGFloat quadrance = CGVectorGetQuadrance(vector);
    if (quadrance > 0.0) {
        CGFloat length = sqrt(quadrance);
        return CGVectorMake(vector.dx / length, vector.dy/length);
    }
    return CGVectorMake(0, 0);
}

static CGVector interpolatedNormalUnitVectorBetween(CGVector vector1, CGVector vector2) {
    CGVector vec1Normal = CGVectorGetNormal(vector1);
    CGVector vec2Normal = CGVectorGetNormal(vector2);
    CGVector vecNormalSum = CGVectorMake(vec1Normal.dx + vec2Normal.dx, vec1Normal.dy + vec2Normal.dy);
    CGVector vecSumNormalized = CGVectorGetNormalized(vecNormalSum);
    if (vecSumNormalized.dx != 0.0 || vecSumNormalized.dy != 0.0) {
        return vecSumNormalized;
    }
    else {
        CGVector vec1Normalized = CGVectorGetNormalized(vector1);
        CGVector vec2Normalized = CGVectorGetNormalized(vector2);
        if (vec1Normalized.dx != 0.0 || vec1Normalized.dy != 0.0) {
            return vec1Normalized;
        }
        else if (vec2Normalized.dx != 0.0 || vec2Normalized.dy != 0.0) {
            return vec2Normalized;
        }
        else {
            return CGVectorMake(1.0, 0.0);
        }
    }
}

@implementation LIFEStrokeSegment
- (instancetype)initWithStrokeSample:(LIFEStrokeSample *)sample {
    self = [super init];
    if (self != nil) {
        _sampleAfter = sample;
        _fromSampleIndex = -2;
    }
    return self;
}
- (CGVector)segmentUnitNormal {
    return CGVectorGetNormalized(CGVectorGetNormal(self.segmentStrokeVector));
}
- (CGVector)fromSampleUnitNormal {
    return interpolatedNormalUnitVectorBetween(self.previousSegmentStrokeVector, self.segmentStrokeVector);
}
- (CGVector)previousSegmentStrokeVector {
    if (self.sampleBefore != nil) {
        CGPoint fromLoc = self.fromSample.location;
        CGPoint beforeLoc = self.sampleBefore.location;
        return CGVectorMake(fromLoc.x - beforeLoc.x, fromLoc.y - beforeLoc.y);
    }
    return self.segmentStrokeVector;
}
- (CGVector)segmentStrokeVector {
    return CGVectorMake(self.toSample.location.x - self.fromSample.location.x, self.toSample.location.y - self.fromSample.location.y);
}
- (CGVector)nextSegmentStrokeVector {
    if (self.sampleAfter != nil) {
        return CGVectorMake(self.sampleAfter.location.x - self.toSample.location.x, self.sampleAfter.location.y - self.toSample.location.y);
    }
    else {
        return self.segmentStrokeVector;
    }
}
- (BOOL)advanceWithSample:(LIFEStrokeSample *)incomingSample {
    if (self.sampleAfter != nil) {
        self.sampleBefore = self.fromSample;
        self.fromSample = self.toSample;
        self.toSample = self.sampleAfter;
        self.sampleAfter = incomingSample;
        self.fromSampleIndex += 1;
        return YES;
    }
    return NO;
}

@end
