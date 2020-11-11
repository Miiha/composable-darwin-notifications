//
//  File.swift
//  
//
//  Created by Michael Kao on 09.11.20.
//

import Foundation
import ComposableArchitecture

public struct DarwinNotificationClient {
  public var postNotification: (DarwinNotification.Name) -> Effect<Never, Never>
  public var observeNotification: (AnyHashable, DarwinNotification.Name) -> Effect<DarwinNotification, Never>
}
