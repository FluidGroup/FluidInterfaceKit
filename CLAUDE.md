# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Update git submodules (required before first build)
make checkout

# Build for iOS
make build

# Run tests
xcodebuild -scheme "FluidInterfaceKit-Package" test \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0.1' | xcbeautify

# Run a single test (example)
xcodebuild -scheme "FluidInterfaceKit-Package" test \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0.1' \
  -only-testing:FluidStackTests/FluidStackControllerTests | xcbeautify
```

## Architecture

FluidInterfaceKit is a UIKit-based framework providing advanced view controller management with customizable transitions. The primary component **FluidStackController** replaces UINavigationController with flexible stacking behavior.

### Core Modules (SPM Libraries)

- **FluidStack** - Main container replacing UINavigationController. Key classes: `FluidStackController`, `FluidViewController`, `FluidGestureHandlingViewController`
- **FluidGesture** - Makes views draggable with `makeDraggable(descriptor:)`
- **FluidPortal** - Portal/layer display system for floating views
- **FluidSnackbar** - Toast/snackbar notifications with gesture support
- **FluidKeyboardSupport** - Keyboard frame tracking and integration
- **FluidTooltipSupport** - Floating tooltips over specific points
- **FluidPictureInPicture** - PiP floating view support
- **FluidStackRideauSupport** - Integration with Rideau modal library

### Transition System

Adding transitions: `AnyAddingTransition` with presets (`.noAnimation`, `.navigationStyle`, `.fadeIn`, `.popup`, `.contextualExpanding`, `.modalIdiom`)

Removing transitions: `AnyRemovingTransition` with presets (`.noAnimation`, `.navigationStyle`, `.fadeOut`, `.vanishing`, `.contextual`, `.modalIdiom`)

Context objects: `AddingTransitionContext`, `RemovingTransitionContext` provide state for animations.

### Extension Pattern

All UIViewControllers gain fluid methods via extension protocol:
- `fluidPush()` / `fluidPop()` - Safe navigation
- `fluidPushUnsafely()` - Unsafe variants
- `fluidStackController(with:)` - Finding strategies

## Code Style

- **Indentation:** 2 spaces
- **MainActor:** Extensively used for thread safety
- **MARK sections:** Properties, Initializers, Functions, ViewController lifecycle
- **Naming:** `Fluid` prefix for all types, camelCase for methods

## Dependencies

- GeometryKit, ResultBuilderKit, Rideau, swiftui-Hosting, swift-rubber-banding (all from FluidGroup)
