# FluidInterfaceKit

## Overview

The goal of this project is to make **Fluid Interface** easy to use.  
Mainly, focusing on **transition** that is intuitive and flexible.

For instance, iOS Home screen provides great flexible user interactions.  
The user can stop opening the app while transitioning vice versa.

Also, context menu in iOS 15 must be a kind of fluid-interface.

Tools for **Fluid Interface** built on top of UIKit.

**[About Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)**  
**[Instagram Threads engineering article](https://about.instagram.com/blog/engineering/on-building-a-fluid-user-interface)**

## Disclamation

> This project is still under development and experimental.  
There is no guarantee to become ready for use in production.

## Requirements

- iOS 12 +
- Swift 5.5
- iPhone platform
- Packages
  - [MatchedTransition](https://github.com/muukii/MatchedTransition)
  - [GeometryKit](https://github.com/muukii/GeometryKit)
  - [ResultBuilderKit](https://github.com/muukii/ResultBuilderKit.git)

- Optional Packages
  - [CompositionKit](https://github.com/muukii/CompositionKit)
  - [MondrianLayout](https://github.com/muukii/MondrianLayout)
  - [TextureSwiftSupport](https://github.com/TextureCommunity/TextureSwiftSupport)

## Roadmap

The number of stars makes this project push forward.

- 100 🌟 TBD
- 200 🌟 TBD
- 300 🌟 TBD

## Showcase

|Instagram Threads like | Apple like |
|---|---|
|<img width=200px src=https://user-images.githubusercontent.com/1888355/147848629-031e1c5c-0c52-4674-8d9a-dad034b6e87f.gif />| <img width=200px src=https://user-images.githubusercontent.com/1888355/147852736-9e926a14-d30f-40ad-9733-c92546d4f8b6.gif /> |

## Installation

**SwiftPM**

```swift
dependencies: [
  .package(url: "https://github.com/muukii/FluidInterfaceKit.git", exact: "<VERSION>")
]
```

## Detail

**2 ways to use**

### Using FluidStackViewController no uses UIKit presentation

`FluidStackViewController` is a container view controller like `UINavigationController` and `UITabBarController`.  
It stacks view controllers on Z-axis to display. 

The transition of adding and removing are supported as well as UIKit's presentation. but it's more designed for flexibility.

### Using only FluidViewController and UIKit presentation

If you only needed just transition and interactive removing without full flexibility.
Those are compatible with using UIKit's presentation.

Use `TransitionViewController` or `FluidViewController`.

## License

MIT

## Author

- [Muukii(Hiroshi Kimura)🇯🇵 ](https://twitter.com/muukii_app)
