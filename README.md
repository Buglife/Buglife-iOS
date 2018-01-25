<p align="center">
	<img src="https://ds9bjnn93rsnp.cloudfront.net/assets/logo/logotype_black_on_transparent_782x256-7256a7ab03e9652908f43be94681bc4ebeff6d729c36c946c346a80a4f8ca245.png" width=300 />
</p>

![Platform](https://img.shields.io/cocoapods/p/Buglife.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Buglife.svg)](https://cocoapods.org/pods/Buglife)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Twitter](https://img.shields.io/badge/twitter-@BuglifeApp-blue.svg)](https://twitter.com/buglifeapp)

Buglife is an awesome bug reporting SDK & web platform for iOS apps. Here's how it works:

1. User takes a screenshot, or stops screen recording
2. User annotates their screenshot & writes feedback
3. Bug reports are pushed to your team's email/Jira/Slack/Asana/wherever you track bugs.

You can also find Buglife for Android [here](https://github.com/buglife/buglife-android).

<p align="center" style="margin-top: 20px; margin-bottom: 20px;">
	<img src="https://i.imgur.com/mdwgDzd.png" />
</p>

---

|   | Main Features |
|---|---------------|
| 👤 | Free + no account required |
| 📖 | Open source |
| 🏃🏽‍♀️ | Fast & lightweight |
| 🎨 | Themeable |
| 📩 | Automatic caching & retry |
| 📜 | Custom form fields, with pickers & multiline text fields  |
| ℹ️ | Advanced logging, with debug / info / warning levels |
| 📎 | Custom attachments, including JSON & SQLite support |
| 🎥 | Attach photos & video from camera roll |
| 📟 | String customization |
| 🌎 | 16 languages supported, with RTL for Arabic + Hebrew |
| 🙈 | Automatic view blurring for sensitive information |
| 👩🏽‍💻 | Written in Objective-C, with full Swift support |

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

### Carthage

Place the following line in your Cartfile:

``` Swift
github "Buglife/Buglife-iOS"
```

Now run `carthage update`. Then drag & drop the Buglife.framework in the Carthage/build folder to your project. Refer to the [Carthage README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for detailed / updated instructions.

### Manually

1. [Download the Buglife SDK](https://www.buglife.com/download-ios-sdk)

2. Unzip it & pull `Buglife.framework` into the Frameworks group in your project. In the following dialog box, make sure you have "Copy items if needed" checked.

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
	Buglife.shared().start(withEmail: "you@yourdomain.com")
	```
	```objective-c
	// Objective-C
	[[Buglife sharedBuglife] startWithEmail:@"you@yourdomain.com"];
	```
	Be sure to replace `you@yourdomain.com` with your own email address; this is where bug reports will be sent to.
	
## Usage

Build & run your app. Once your app is running, shake your device (\^⌘Z in the simulator) to report a bug! Bug reports are sent directly to your email address.

You can customize how the bug reporter is invoked. **Rather than shake, we recommend configuring the bug reporter to be shown when a user takes a screenshot:**

```swift
// Swift
Buglife.shared().invocationOptions = .screenshot
```
```objective-c
// Objective-C
[Buglife sharedBuglife].invocationOptions = LIFEInvocationOptionsScreenshot;
```

To learn more about customizing Buglife, refer to the [documentation](https://www.buglife.com/docs).

## Requirements

* Xcode 8 or later
* iOS 9 or later

## Contributing

We don't have any contributing guidelines at the moment, but feel free to submit pull requests & file issues within GitHub!
