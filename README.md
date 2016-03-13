![Buglife: Awesome Bug Reporting](https://d19rwogc3unx97.cloudfront.net/assets/logo/logotype_navy_on_transparent_776x256-a8018f3eb096b0f4e270ec0b63d8ff9dfafcdb242855f09e20f249ef7d3c0367.png)

![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Buglife.svg)
![Platform](https://img.shields.io/cocoapods/p/Buglife.svg)
![Twitter](https://img.shields.io/badge/twitter-@BuglifeApp-blue.svg)

Buglife is an awesome bug reporting SDK & web platform for iOS apps. For more info, visit [Buglife.com](https://www.buglife.com).

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

2. Add the following to your app delegate's application:didFinishLaunchingWithOptions: method.
	
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

Build & run your app; you should see a floating Buglife button. Tap this button to report a bug; bug reports will be sent directly to your email address!

Don't like the floating Buglife button? You can configure Buglife to invoke the bug reporter via manual screenshots or shaking the device. See the header docs in [Buglife.h](Buglife.framework/Versions/A/Headers/Buglife.h) for more info!
