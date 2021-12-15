import StorybookKit

let book = Book(title: "MyBook") {

  BookNavigationLink(title: "Demo") {
    BookPush(title: "Demo") {
      DemoViewController()
    }
    BookPresent(title: "Instagram Threads") {
      let controller = DemoThreadsMessagesViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
    BookPush(title: "ControlCenter") {
      DemoControlCenterViewController()
    }
  }
}
