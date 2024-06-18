//
//  ContentView.swift
//  Demo
//
//  Created by Muukii on 2021/04/24.
//

import FluidSnackbar
import FluidStack
import SwiftUI

@MainActor
let snackbarController = FloatingDisplayController(
  edgeTargetSafeArea: .init(
    top: .notificationWindow,
    right: .activeWindow,
    bottom: .activeWindow,
    left: .activeWindow
  )
)

struct FloatingDisplayKitContentView: View {
  var body: some View {
    Form {

      Button("Display Bar + SwiftUI content") {

        snackbarController.display(
          context: .init(
            position: .top,
            transition: .slideIn,
            content: {
              ZStack {
                Image(systemName: "star")
                  .resizable()
                  .frame(width: 24, height: 24)
              }
              .background(Color.red)
            }
          ),
          waitsInQueue: false
        )

      }

      Button("Display Bar") {

        snackbarController.display(
          context: .init(
            viewBuilder: {
              DemoSnackbarView(text: "Hello")
            },
            position: .top, 
            transition: .slideIn
          ),
          waitsInQueue: false
        )

      }

      Button("Display Popup") {
        snackbarController.display(
          context: .init(
            viewBuilder: {
              DemoSnackbarView(text: "Hello")
            },
            position: .center,
            transition: FloatingDisplayPopupTransition()
          ),
          waitsInQueue: false
        )
      }

      Button("Display Bottom to safe area") {
        snackbarController.display(
          context: .init(
            viewBuilder: {
              DemoSnackbarView(text: "Hello")
            },
            position: .bottom(paddingBottom: 8),
            transition: FloatingDisplayPopupTransition()
          ),
          waitsInQueue: false
        )
      }

      Button("Display Top to safe area") {
        snackbarController.display(
          context: .init(
            viewBuilder: {
              DemoSnackbarView(text: "Hello")
            },
            position: .top,
            transition: FloatingDisplayPopupTransition()
          ),
          waitsInQueue: false
        )
      }

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    FloatingDisplayKitContentView()
  }
}
