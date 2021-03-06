// Copyright © 2020 Michael Kao

import Foundation

public struct DarwinNotification: Equatable {
  var name: Name

  internal init(_ name: Name) {
    self.name = name
  }

  public struct Name: Equatable {
    internal var rawValue: CFString
  }

  public var value: String {
    self.name.rawValue as String
  }
}

extension DarwinNotification.Name {
  public init(_ rawValue: String) {
    self.rawValue = rawValue as CFString
  }

  internal init(_ cfNotificationName: CFNotificationName) {
    rawValue = cfNotificationName.rawValue
  }

  public static func == (lhs: DarwinNotification.Name, rhs: DarwinNotification.Name) -> Bool {
    return (lhs.rawValue as String) == (rhs.rawValue as String)
  }
}

extension DarwinNotification.Name: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self = DarwinNotification.Name(stringLiteral)
  }
}
