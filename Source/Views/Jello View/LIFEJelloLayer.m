//
//  LIFEJelloLayer.m
//  Copyright (C) 2018 Buglife, Inc.
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

#import "LIFEJelloLayer.h"
#import "LIFEMacros.h"

@implementation LIFEJelloLayer

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
    [super addAnimation:anim forKey:key];
    
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        let basicAnimation = (CABasicAnimation *)anim;
        
        if ([basicAnimation.keyPath isEqualToString:NSStringFromSelector(@selector(position))]) {
            if ([self.delegate conformsToProtocol:@protocol(LIFEJelloLayerDelegate)]) {
                id<LIFEJelloLayerDelegate> delegate = (id<LIFEJelloLayerDelegate>)self.delegate;
                [delegate jelloLayer:self willStartAnimation:basicAnimation];
            }
        }
    }
}

@end
