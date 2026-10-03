import UIKit

@_exported import Wrap
@_exported import MockKit
@_exported import Ne

/// Provides the application's entry point; each scene owns its demo window.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
}

/// Creates and retains the catalog window for the connected UIKit scene.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {

    guard let windowScene = scene as? UIWindowScene else { return }

    let newWindow = UIWindow(windowScene: windowScene)
    newWindow.rootViewController = RootContainerViewController()
    newWindow.tintColor = .systemBlue//.neon(.violet)
    newWindow.makeKeyAndVisible()
    self.window = newWindow
  }

}
