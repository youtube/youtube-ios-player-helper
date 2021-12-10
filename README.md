# YouTube-Player-iOS-Helper

[![Version](https://cocoapod-badges.herokuapp.com/v/youtube-ios-player-helper/badge.png)](https://cocoapods.org/pods/youtube-ios-player-helper)
[![Platform](https://cocoapod-badges.herokuapp.com/p/youtube-ios-player-helper/badge.png)](https://cocoapods.org/pods/youtube-ios-player-helper)

## Overview

To run the example project; clone the repo, and run `pod install` from the Project directory first.  For a simple tutorial see this Google Developers article - [Using the YouTube Helper Library to embed YouTube videos in your iOS application](https://developers.google.com/youtube/v3/guides/ios_youtube_helper).

## Installation
### CocoaPods
YouTube-Player-iOS-Helper is available through [CocoaPods](http://cocoapods.org). To install
the library, add the following line to your Podfile and replace "x.y.z" with the latest version.

    pod "youtube-ios-player-helper", "~> x.y.z"

### Swift Package Manager 
Add the following line to the dependencies in your `Package.swift`:
```swift
.package("https://github.com/youtube/youtube-ios-player-helper.git", from: "x.y.z")
```
Add `YouTubeiOSPlayerHelper` to your target's dependencies.
```swift
.target(name: "TargetName",
        dependencies: [
          "YouTubeiOSPlayerHelper"
        ]
      )
```

## Usage
After installing in your project, to use the library:

  1. Drag a UIView the desired size of your player onto your Storyboard.
  2. Change the UIView's class in the Identity Inspector tab to YTPlayerView
  3. Import "YTPlayerView.h" in your ViewController.
  4. Add the following property to your ViewController's header file:
```objc
    @property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
```
  5. Load the video into the player in your controller's code with the following code:
```objc
    [self.playerView loadWithVideoId:@"M7lc1UVf-VE"];
```
  6. Run your code!

See the sample project for more advanced uses, including passing additional player parameters and
working with callbacks via YTPlayerViewDelegate.

## Original Authors

- Ikai Lan
- Ibrahim Ulukaya
- Yoshifumi Yamaguchi

## License

YouTube-Player-iOS-Helper is available under the Apache 2.0 license. See the LICENSE file for more info.
