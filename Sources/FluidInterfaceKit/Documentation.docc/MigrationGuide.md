
# Migration Guide

## Always use `fluidPop` to dismiss, unwind.

// TODO:

## `fuidPush` restricts types of view controllers that can display.

// TODO:

## Avoid using modal-presentation

`fluidPush` fails in a modally presented view controller unless that has FluidStackController.

## To Display UIAlertController

// TODO:

Use the pure way in UIKit’s ViewController

```swift
let alert: UIAlertController

self.present(alert, animated: true)
```
