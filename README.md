![Buglife: Awesome Bug Reporting](https://ds9bjnn93rsnp.cloudfront.net/assets/logo/logotype_black_on_transparent_782x256-7256a7ab03e9652908f43be94681bc4ebeff6d729c36c946c346a80a4f8ca245.png)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Buglife.svg)](https://cocoapods.org/pods/Buglife)
![Platform](https://img.shields.io/cocoapods/p/Buglife.svg)
[![Twitter](https://img.shields.io/badge/twitter-@BuglifeApp-blue.svg)](https://twitter.com/buglifeapp)

Buglife is an awesome bug reporting SDK & web platform for iOS apps.
For more info, visit [Buglife.com](https://www.buglife.com).

In a hurry? Try out our [iOS Demo project](https://github.com/Buglife/Buglife-iOS-Demo)!

## Installation

### CocoaPods

To integrate Buglife into your Xcode project using [CocoaPods](https://cocoapods.org), specify it in your `Podfile`:

```ruby
pod 'Buglife'
```

Then, run the following command:

```bash
$ pod install
```

### Manually

1. [Download the Buglife SDK](https://www.buglife.com/download-ios-sdk)

2. Unzip it & pull `Buglife.framework` into the Frameworks group in your project. In the following dialog box, make sure you have "Copy items if needed" checked.

3. Make sure your project links to the following system frameworks. You can add these under your project's Build Phases tab, under Link Binary With Libraries.
	* CoreTelephony.framework
	* SystemConfiguration.framework

## Code

1. Import the Buglife framework header into your app delegate.

    ```swift
    // Swift
    import Buglife
    ```
    
    ```objective-c
    // Objective-C
    #import <Buglife/Buglife.h>
    ```

2. Add the following to your app delegate's `application:didFinishLaunchingWithOptions:` method.
	
	```swift
	// Swift
	Buglife.sharedBuglife().startWithEmail("you@yourdomain.com")
	```
	```objective-c
	// Objective-C
	[[Buglife sharedBuglife] startWithEmail:@"you@yourdomain.com"];
	```
	Be sure to replace `you@yourdomain.com` with your own email address; this is where bug reports will be sent to.
	
## Usage

Build & run your app. Once your app is running, shake your device (\^⌘Z in the simulator) to report a bug! Bug reports are sent directly to your email address.

Buglife offers numerous customizations & advanced features, including:

* Different invocation methods (i.e. hook into device screenshots to report a bug)
* Custom attachments
* Programmatic view blurring
* QA Mode
* String customization
* Automatic + manual user email collection

And more. Check out the Buglife [documentation page](https://www.buglife.com/docs) for more info!
