
# Migration Guide

## Drop UINavigationController and Modal-presentation, use FluidStackController instead.

Try to think about creating all of the transitions with UINavigationController.
Because it could say FluidStackController is just like yet another UINavigationController.

Motivation is here (Motivation section): [https://muukii.github.io/FluidInterfaceKit/documentation/fluidinterfacekit/](https://muukii.github.io/FluidInterfaceKit/documentation/fluidinterfacekit/)

## Every single transition are dispatched by fluidPush on FluidStackController

```swift
sourceViewController.fluidPush(
  destinationViewController, 
  target: .current,
  relation: .modality
)
```

## Always use fluidPop to dismiss instead of UIViewController.dismiss, UINavigationController.popViewController

```swift
destinationViewController.fluidPop()
```

## fuidPush accepts only specified types of UIViewController

- FluidViewController
- FluidPopoverViewController
- FluidRideauViewController (in extended module)

## How view-tree works

Tree (abstract)

- UIWindow
  - View ← UIViewController
    - View ← FluidStackController
      - View ← (pushed content view controller)
      - View ← (pushed content view controller)
      - View ← (pushed content view controller)


## Avoid using modal-presentation

`fluidPush` fails in a modally presented view controller unless that has FluidStackController.

- UIWindow
  - View ← UIViewController
    - View ← FluidStackController
      - ...
    - TransitionView (created by modal-presentation, style: .fullScreen)

Basically, modal-presentation adds a new container view to host UIViewController on top of the current tree.
Unless specifying presentation-context or setting modal-presentation style of contextual options.

As FluidStackController works similarly to UINavigationController, it needs to create another FluidStackController on top of the modal in order to display another view controller above the modal.

Or present a FluidStackController as modal-presentation, then pushing view controllers.

## To display UIAlertController

UIAlertController is built on top of some internal APIs.
We can’t change modal-presentations style, always they present as full-screen.
Adding as a child view controller won’t work.

Use the pure way in UIKit’s ViewController

```swift
let alert: UIAlertController

self.present(alert, animated: true)
```

## Setting up to support your app display by fluid-push

As to push a view controller to UINavigationController, you must prepare UINavigationController in the hierarchy. fluid-push needs the same thing.

At least the app must have one or more FluidStackController to host view controllers.
Wrapping the entrypoint view controller with FluidStackController as following,

Before

- UIWindow
  - Entrypoint(UIViewController)

After

- UIWindow
  - Stack (FluidStackController)
    - Entrypoint(UIViewController)

## How fluid-push works

`fluidPush` method gets a target parameter.
This parameter indicates how to find a target stack controller to display the given view controller.

As built-in paramter, we have `current`, `nearestAncestor`, `root` and `identifier(_:)`

It’s like pushing a view controller into another UINavigationController from descendants.

FluidStackController has an identifier, we can create custom query that uses the identifiers.

```swift
extension FluidStackController.Identifier {

  /// front of tab
  public static let loggedOut: Self = .init("loggedOut")

  /// front of tab
  public static let loggedIn: Self = .init("loggedIn")

}

extension UIViewController.FluidStackFindStrategy {

  /**
  Find stack controller that can display as full-screen.
  (Above TabBarControler.)
  */
  public static let fullScreen: Self = .matching(
    name: "fullScreen",
    strategies: [
      .identifier(.loggedIn),
      .identifier(.loggedOut),
      .root,
    ]
  )

}
```

```swift
sourceViewController.fluidPush(
  destinationViewController, 
  target: .fullScreen,
  relation: .modality
)
```
