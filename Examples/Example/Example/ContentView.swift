//
//  ContentView.swift
//  Example
//
//  Created by Michael Kao on 13.11.20.
//

import ComposableArchitecture
import ComposableDarwinNotifications
import SwiftUI

struct AppState: Equatable {
  var count: Int = 0
}

enum AppAction: Equatable {
  case onAppear
  case notificaitonResponse(DarwinNotification)
}

struct AppEnvironment {
  var darwinNotificationClient: DarwinNotificationClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  struct Id: Hashable {}

  switch action {
  case .onAppear:
    return environment.darwinNotificationClient.observeNotification(Id(), "example.action")
      .map(AppAction.notificaitonResponse)

  case .notificaitonResponse:
    state.count += 1
    return .none
  }
}

struct ContentView: View {
  let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment(darwinNotificationClient: .live)
  )

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Text("Count: \(viewStore.count)")
        .padding()
        .onAppear { viewStore.send(.onAppear) }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
