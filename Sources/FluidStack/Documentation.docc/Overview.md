# ``FluidStack``

**FluidInterfaceKit** provides the advanced infrastructure for your iPhone apps.

Built on top of UIKit, replace UIKit standard transitions with the custom components.

It provides components that make your app more flexible - interactive and interruptible transition, free to unwind view controllers without `pop` or `dismiss`.

That would fit to create fully customized UI apps such as Snapchat, Zenly, Uber, Instagram Threads.

FluidInterfaceKit's essential component is `FluidStackController`, which stacks view controllers with customized transitions.

Apps run with this component, only stacking but it can get flexibility instead.

- [About Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)

- [Instagram Threads engineering article](https://about.instagram.com/blog/engineering/on-building-a-fluid-user-interface)

![image](FluidStack)


## Requirements

- iOS 12 +
- Swift 5.6
- iPhone platform (Currently iPad not supported)
- Packages
    - [MatchedTransition](https://github.com/muukii/MatchedTransition)
    - [GeometryKit](https://github.com/muukii/GeometryKit)
    - [ResultBuilderKit](https://github.com/muukii/ResultBuilderKit.git)

## Optional packages

With these packages, productivity may gain.

- [CompositionKit](https://github.com/muukii/CompositionKit)
- [MondrianLayout](https://github.com/muukii/MondrianLayout)
- [TextureSwiftSupport](https://github.com/TextureCommunity/TextureSwiftSupport)

## Motivation

Normally, UIKit offers us to get screen management with `UIViewController.present`, `UIViewController.dismiss`, `UINavigationController.push`, `UINavigationController.pop`.

In the case of a view controller that needs to display on modal and navigation, that view controller requires to supports both.In modal, what if it uses `navigationItem`, should be wrapped with `UINavigationController` to display.

Moreover, that view controller would consider how to dismiss itself unless handled by outside.Pop or dismiss which depends on the context.

**FluidInterfaceKit** provides `FluidStackController`, which is similar to `UINavigationController`. It offers all of the view controllers that are managed in stacking as a child of the stack.

Try to think of it with what if we're using `UINavigationController`.All view controllers will display on that, and push to the next view controller, what if needed nesting, push another UINavigationController.Expression of transition would not be a problem, we can create a custom transition, so it can be like a modal presentation - slide in from the bottom.

If the app runs like that, we only use `push` and `pop` to manage screens except for the special case of using `present` - UIAlertController or other modals in third-party libraries. Still, modals work very well since nobody use presentation.

As above mentioned, `FluidStackController` is similar to `UINavigationController`, it just stacks view controllers that are managed as a child.What difference with `UINavigationController` is **transitions**, it provides interfaces to create custom transition and it supports more flexibility.

Custom transitions that run with `UIViewControllerAnimatedTransitioning` have some limitations in modal-presentation and push-transition.It supports cancellation, which would be a part of flexibility, but it's not enough.

Please see what happens in iOS Home Screen, it supports completely responding to user interaction - opening an app, canceling opening by Home bar, moving back the home, then opening the app again by touch.

## Strategy

FluidInterfaceKit provides flexibility in UIKit’s transitioning operation.
Instead of using modal-presentation, take advantage of [implementing a container view controller](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html).
Which stacks view controllers in Z-axis, representing like modal presentation.

A container view controller actually manages a view of view controller with `addSubview` and `removeFromSuperview`. That we have to manage the life cycle of theirs, interruptions completely. But we use this for getting flexibility.

