// Copyright © 2020 Michael Kao

import XCTest
import ComposableArchitecture
import Combine
@testable import ComposableDarwinNotifications

final class DarwinNotificationClientTests: XCTestCase {
  var cancellables = Set<AnyCancellable>()

  func testExample() {
    let client = DarwinNotificationClient.live
    var notifications: [DarwinNotification] = []

    let observeExpectation = XCTestExpectation()
    observeExpectation.expectedFulfillmentCount = 2

    struct Id: Hashable {}
    client.observeNotification(Id(), "blob")
      .sink {
        notifications.append($0)
        observeExpectation.fulfill()
      }
      .store(in: &cancellables)

    let firstPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        firstPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    let secondPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        secondPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    let thirdPostExpectation = XCTestExpectation()
    client.postNotification("bar")
      .sink(receiveCompletion: { _ in
        thirdPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [firstPostExpectation, secondPostExpectation, thirdPostExpectation, observeExpectation], timeout: 3.0)

    XCTAssertEqual(
      notifications,
      [
        DarwinNotification("blob"),
        DarwinNotification("blob")
      ]
    )
  }

  func testTwoObservers() {
    let client = DarwinNotificationClient.live
    var notifications1: [DarwinNotification] = []
    var notifications2: [DarwinNotification] = []

    let observeExpectation1 = XCTestExpectation()
    observeExpectation1.expectedFulfillmentCount = 1

    struct Id1: Hashable {}
    client.observeNotification(Id1(), "blob")
      .sink {
        notifications1.append($0)
        observeExpectation1.fulfill()
      }
      .store(in: &cancellables)

    let observeExpectation2 = XCTestExpectation()
    observeExpectation2.expectedFulfillmentCount = 2

    struct Id2: Hashable {}
    client.observeNotification(Id2(), "blob")
      .sink {
        notifications2.append($0)
        observeExpectation2.fulfill()
      }
      .store(in: &cancellables)

    let postExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [observeExpectation1, observeExpectation2, postExpectation], timeout: 3.0)

    XCTAssertEqual(notifications1, [DarwinNotification("blob")])
    XCTAssertEqual(notifications2, [DarwinNotification("blob")])
  }

  func testTwoObserversOneNotification() {
    let client = DarwinNotificationClient.live
    var notifications1: [DarwinNotification] = []
    var notifications2: [DarwinNotification] = []

    let observeExpectation1 = XCTestExpectation()
    observeExpectation1.expectedFulfillmentCount = 1

    struct Id1: Hashable {}
    client.observeNotification(Id1(), "blob")
      .sink {
        notifications1.append($0)
        observeExpectation1.fulfill()
      }
      .store(in: &cancellables)

    struct Id2: Hashable {}
    client.observeNotification(Id2(), "blobbo")
      .sink {
        notifications2.append($0)
      }
      .store(in: &cancellables)

    let postExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [observeExpectation1, postExpectation], timeout: 3.0)

    XCTAssertEqual(notifications1, [DarwinNotification("blob")])
    XCTAssertEqual(notifications2, [])
  }

  func testCancellation() {
    let client = DarwinNotificationClient.live
    var notifications: [DarwinNotification] = []

    let observeExpectation = XCTestExpectation()
    observeExpectation.expectedFulfillmentCount = 1

    struct Id: Hashable {}
    let cancellable = client.observeNotification(Id(), "blob")
      .sink {
        notifications.append($0)
        observeExpectation.fulfill()
      }

    let firstPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        firstPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [observeExpectation, firstPostExpectation], timeout: 1.0)

    cancellable.cancel()

    let secondPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        secondPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    let secondObserverExpectation = XCTestExpectation()
    _ = XCTWaiter.wait(for: [secondPostExpectation, secondObserverExpectation], timeout: 1.0)
    XCTAssertEqual(notifications, [DarwinNotification("blob")])
  }
}
