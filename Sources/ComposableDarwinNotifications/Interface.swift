// Copyright © 2020 Michael Kao

import Foundation
import ComposableArchitecture

public struct DarwinNotificationClient {
  public var postNotification: (DarwinNotification.Name) -> Effect<Never, Never>
  public var observeNotification: (AnyHashable, DarwinNotification.Name) -> Effect<DarwinNotification, Never>
}
