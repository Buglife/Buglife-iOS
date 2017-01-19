//
//  LIFEAppearance.h
//  Buglife
//
//  Copyright (c) 2017 Buglife, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  To customize the visual appearance of Buglife views & 
 *  view controllers, get an instance of an object conforming
 *  to this protocol using the `Buglife.appearance` property,
 *  then use any of that object's corresponding LIFEAppearance
 *  properties.
 *
 *  Example:
 *
 *  ```objc
 *  // Objective-C
 *  [Buglife sharedBuglife].appearance.tintColor = [UIColor redColor];
 *  ```
 *
 *  ```swift
 *  // Swift
 *  Buglife.shared().apperance.tintColor = .red
 *  ```
 *
 *  @see `Buglife.appearance`
 */
@protocol LIFEAppearance <NSObject>

/**
 *  The color of interactive elements, such as navigation bar buttons.
 */
@property (nonatomic, null_resettable) UIColor *tintColor;

/**
 *  The background color of navigation bars & toolbars.
 */
@property (nonatomic, null_resettable) UIColor *barTintColor;

/**
 *  Display attributes for the bar’s title text.
 */
@property (nonatomic, null_resettable, copy) NSDictionary<NSString *,id> *titleTextAttributes;

/**
 *  The status bar style, if & when the status bar is visible.
 */
@property (nonatomic) UIStatusBarStyle statusBarStyle;

@end
