import StorybookKit

let book = Book(title: "MyBook") {

  BookNavigationLink(title: "Demo") {
    BookPush(title: "Demo") {
      DemoViewController()
    }
    BookPush(title: "Threads") {
      DemoThreadsMessagesViewController()
    }
    BookPush(title: "ControlCenter") {
      DemoControlCenterViewController()
    }
  }
}
