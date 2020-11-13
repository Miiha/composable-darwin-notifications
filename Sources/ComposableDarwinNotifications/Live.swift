// Copyright © 2020 Michael Kao

import Foundation
import Combine
import ComposableArchitecture

extension DarwinNotificationClient {
  static var live: DarwinNotificationClient {
    guard let center = CFNotificationCenterGetDarwinNotifyCenter() else {
      fatalError("Invalid CFNotificationCenter")
    }

    return Self(
      postNotification: { name in
        Effect.fireAndForget {
          CFNotificationCenterPostNotification(
            center,
            CFNotificationName(rawValue: name.rawValue),
            nil,
            nil,
            false
          )
        }
        .subscribe(on: queue.eraseToAnyScheduler())
        .eraseToEffect()
      },
      observeNotification: { id, name in
        Effect.run { subscriber in
          let observer = Observer(
            id: id,
            name: name
          )
          dependencies[id] = observer
          subscribers[id] = subscriber

          let callback: CFNotificationCallback = { (center, observer, name, object, userInfo) in
            queue.async {
              guard let cfName = name, let opaqueObserver = observer else {
                return
              }

              let observer = Unmanaged<Observer>.fromOpaque(opaqueObserver).takeUnretainedValue()
              guard let subscriber = subscribers[observer.id] else { return }
              let notificationName = DarwinNotification.Name(cfName)
              let notification = DarwinNotification(notificationName)

              subscriber.send(notification)
            }
          }

          let observerPointer = Unmanaged.passUnretained(observer).toOpaque()
          CFNotificationCenterAddObserver(
            center,
            observerPointer,
            callback,
            name.rawValue,
            nil,
            .coalesce
          )
          return AnyCancellable {
            guard let observer = dependencies[id] else { return }

            let notificationName = CFNotificationName(rawValue: name.rawValue)
            let observerPointer = Unmanaged.passUnretained(observer).toOpaque()
            CFNotificationCenterRemoveObserver(
              center,
              observerPointer,
              notificationName,
              nil
            )
            dependencies[id] = nil
            subscribers[id] = nil
          }
        }
        .subscribe(on: queue.eraseToAnyScheduler())
        .eraseToEffect()
      }
    )
  }
}

private let queue = DispatchQueue(
  label: "DarwinNotificationClient",
  qos: .default,
  attributes: [],
  autoreleaseFrequency: .workItem
)
private var subscribers = [AnyHashable: Effect<DarwinNotification, Never>.Subscriber]()
private var dependencies = [AnyHashable: Observer]()

fileprivate final class Observer: Hashable {
  let id: AnyHashable
  let name: DarwinNotification.Name

  init(id: AnyHashable, name: DarwinNotification.Name) {
    self.id = id
    self.name = name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Observer, rhs: Observer) -> Bool {
    lhs.id == rhs.id && lhs.name.rawValue as String == rhs.name.rawValue as String
  }
}
