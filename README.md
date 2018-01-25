# KKBOX Open API Swift Developer SDK for iOS/macOS/watchOS/tvOS

Copyright © 2018 KKBOX All Rights Reserved.

[![Support](https://img.shields.io/badge/macOS-10.10-blue.svg)](https://www.apple.com/tw/macos)&nbsp;
[![Support](https://img.shields.io/badge/iOS-9-blue.svg)](https://www.apple.com/tw/ios)&nbsp;
[![Support](https://img.shields.io/badge/watchOS-2-blue.svg)](https://www.apple.com/tw/watchos)&nbsp;
[![Support](https://img.shields.io/badge/tvOS-9-blue.svg)](https://www.apple.com/tw/tvos)&nbsp;

The is a pure Swift implementation of a client to access KKBOX's Open
API.  You can easily integrate the SDK into your
iOS/macOS/watchOS/tvOS project using Swift Package Manager or
CocoaPods.

The SDK leverages lots of power features of Swift programming
language, such as wrapping API responses into enums, and the JSON
encoder/decoder since Swift 4.

On the other hand, the SDK could not be called in your Objective-C
code direclty. If you need to work with KKBOX's Open API in your
Objective-C code, you may need to wrap the SDK in your own bridging
code, or, you may want to take a look of KKBOX's
[Objective-C SDK](https://github.com/KKBOX/OpenAPI-ObjectiveC)

For further information, please visit [KKBOX Developer Site](https://docs-en.kkbox.codes).

## Requirement

The SDK supports

- Swift 4
- 📱 iOS 9.x or above
- 💻 Mac OS X 10.10 or above
- ⌚️ watchOS 2.x or above
- 📺 tvOS 9.x or above

## Build ⚒

You need the latest Xcode and macOS. Xcode 9 and macOS 10.13 High
Sierra are recommended.

## Installation

### CocoaPods

The SDK supports CocoaPods. Please add `pod 'KKBOXOpenAPISwift'`
to your Podfile, and then call `pod install`.

### Swift Package Manager

Add the project as a dependency to your Package.swift:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "KKBOXOpenAPI-test",
    products: [
        .executable(name: "KKBOXOpenAPI-test", targets: ["YourTargetName"])
    ],
    dependencies: [
        .package(url: "https://github.com/zonble/OpenAPI-Swift", .upToNextMinor(from: "1.1.0"))
    ],
    targets: [
        .target(name: "YourTargetName", dependencies: ["OpenAPI-Swift"], path: "./Path/To/Your/Sources")
    ]
)
```

## Usage

To start using the SDK, you need to create an instance of KKBOXOpenAPI.

``` swift
let API = KKBOXOpenAPI(clientID: "YOUR_CLIENT_ID", secret: "YOUR_CLIENT_SECRET")
```

Then, ask the instance to fetch an access token by passing a client credential.

``` swift
_ = try? self.API.fetchAccessTokenByClientCredential { result in
    switch result {
    case .error(let error):
        // Handle error...
    case .success(_):
        // Successfully logged-in
    }
}
```

Finally, you can start to do the API calls. For example, you can fetch the details
of a song track by calling 'fetchTrack'.

``` swift
_ = try? self.API.fetch(track: "4kxvr3wPWkaL9_y3o_") { result in
    switch result {
    case .error(let error):
        // Handle error...
    case .success(let track):
        // Handle the song track.
    }
}
```

You can develop your app using the SDK with Swift or Objective-C programming
language, although we have only Swift sample code here.

## API Documentation 📖

- Documentation for the SDK is available at https://zonble.github.io/OpenAPI-Swift/ .
- KKBOX's Open API documentation is available at https://developer.kkbox.com/ .

## License

Copyright 2018 KKBOX Technologies Limited

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
