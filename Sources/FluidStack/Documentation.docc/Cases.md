# Cases

Here is a list of common use cases and how to achieve them.

Q. How to disable offloading when the view controller needs to be transparent?

Use `UIViewController/fluidStackContentConfiguration`

```swift
fluidStackContentConfiguration.contentType = .overlay
```

Q. How to disable updating status bar style according to the top view controller in Stack?

Use `UIViewController/fluidStackContentConfiguration`

```swift
fluidStackContentConfiguration.capturesStatusBarAppearance = false
```

Q. How to pop to root view controller

(Depends on configuration if it removes the root view controller)

```swift
fluidStackController.removeAllViewController(transition: .vanishing())
```

Q. How to hide navigationBar?

```swift
navigationItem.fluidIsEnabled = false
```

