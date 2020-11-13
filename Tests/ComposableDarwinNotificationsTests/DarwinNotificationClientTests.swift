// Copyright © 2020 Michael Kao

import XCTest
import ComposableArchitecture
import Combine
@testable import ComposableDarwinNotifications

final class DarwinNotificationClientTests: XCTestCase {
  var cancellables = Set<AnyCancellable>()

  func testObservation() {
    let client = DarwinNotificationClient.live
    var notifications: [DarwinNotification] = []

    let observerExpectation = XCTestExpectation()
    struct Id: Hashable {}
    client.observeNotification(Id(), "blob")
      .sink { notifications.append($0); observerExpectation.fulfill() }
      .store(in: &cancellables)

    let postExpectation = XCTestExpectation()
    postExpectation.expectedFulfillmentCount = 3

    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    client.postNotification("bar")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [postExpectation, observerExpectation], timeout: 1.0)

    XCTAssertEqual(notifications, [DarwinNotification("blob"), DarwinNotification("blob")])
  }

  func testTwoObservers() {
    let client = DarwinNotificationClient.live
    var notifications1: [DarwinNotification] = []
    var notifications2: [DarwinNotification] = []

    let firstObserverExpectation = XCTestExpectation()
    struct Id1: Hashable {}
    client.observeNotification(Id1(), "blob")
      .sink { notifications1.append($0); firstObserverExpectation.fulfill() }
      .store(in: &cancellables)

    let secondObserverExpectation = XCTestExpectation()
    struct Id2: Hashable {}
    client.observeNotification(Id2(), "blob")
      .sink { notifications2.append($0); secondObserverExpectation.fulfill() }
      .store(in: &cancellables)

    let postExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [postExpectation, firstObserverExpectation, secondObserverExpectation], timeout: 1.0)

    XCTAssertEqual(notifications1, [DarwinNotification("blob")])
    XCTAssertEqual(notifications2, [DarwinNotification("blob")])
  }

  func testTwoObserversOneNotification() {
    let client = DarwinNotificationClient.live
    var notifications1: [DarwinNotification] = []
    var notifications2: [DarwinNotification] = []

    let firstObserverExpectation = XCTestExpectation()
    struct Id1: Hashable {}
    client.observeNotification(Id1(), "blob")
      .sink { notifications1.append($0); firstObserverExpectation.fulfill() }
      .store(in: &cancellables)

    let secondObserverExpectation = XCTestExpectation()
    struct Id2: Hashable {}
    client.observeNotification(Id2(), "blobbo")
      .sink { notifications2.append($0); secondObserverExpectation.fulfill() }
      .store(in: &cancellables)

    let postExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        postExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [postExpectation, firstObserverExpectation, secondObserverExpectation], timeout: 1.0)

    XCTAssertEqual(notifications1, [DarwinNotification("blob")])
    XCTAssertEqual(notifications2, [])
  }

  func testCancellation() {
    let client = DarwinNotificationClient.live
    var notifications: [DarwinNotification] = []

    struct Id: Hashable {}
    let cancellable = client.observeNotification(Id(), "blob")
      .sink { notifications.append($0) }

    let firstPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        firstPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [firstPostExpectation], timeout: 1.0)

    cancellable.cancel()

    let secondPostExpectation = XCTestExpectation()
    client.postNotification("blob")
      .sink(receiveCompletion: { _ in
        secondPostExpectation.fulfill()
      }, receiveValue: { _ in })
      .store(in: &cancellables)

    _ = XCTWaiter.wait(for: [secondPostExpectation], timeout: 1.0)
    XCTAssertEqual(notifications, [DarwinNotification("blob")])
  }
}
