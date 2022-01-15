import UIKit

@_exported import Wrap
@_exported import MockKit
@_exported import Ne

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let newWindow = UIWindow()
    newWindow.rootViewController = RootContainerViewController()
    newWindow.tintColor = .neon(.violet)
    newWindow.makeKeyAndVisible()
    self.window = newWindow
    return true
  }

}
