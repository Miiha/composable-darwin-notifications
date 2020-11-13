//
//  ActionRequestHandler.swift
//  Action
//
//  Created by Michael Kao on 13.11.20.
//

import UIKit
import MobileCoreServices
import ComposableArchitecture
import ComposableDarwinNotifications

struct ExtensionState: Equatable {
}

enum Action: Equatable {
  case beginRequest
}

let reducer = Reducer<ExtensionState, Action, DarwinNotificationClient> { state, action, client in
  switch action {
  case .beginRequest:
    return client.postNotification("example.action").fireAndForget()
  }
}

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

  let store = Store(
    initialState: ExtensionState(),
    reducer: reducer,
    environment: DarwinNotificationClient.live
  )

  func beginRequest(with context: NSExtensionContext) {
    ViewStore(store).send(.beginRequest)
    context.completeRequest(returningItems: [], completionHandler: nil)
  }
}
