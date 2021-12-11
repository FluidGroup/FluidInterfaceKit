import StorybookKit

let book = Book(title: "MyBook") {

  BookNavigationLink(title: "Demo") {
    BookPush(title: "Demo") {
      DemoViewController()
    }
  }
}
