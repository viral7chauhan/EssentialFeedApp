//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Viral on 02/01/22.
//

import XCTest
import EssentialFeed

class FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
        case deletion
        case insert(item: [FeedItem], timestamp: Date)
    }

    private(set) var receivedMsg = [ReceivedMessage]()
    private var deleteCompletions = [DeleteCompletion]()
    private var insertCompletions = [InsertCompletion]()

    func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        deleteCompletions.append(completion)
        receivedMsg.append(.deletion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertCompletion) {
        insertCompletions.append(completion)
        receivedMsg.append(.insert(item: items, timestamp: timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }
}

class LocalFeedLoader {
    let store: FeedStore
    let timestamp: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.timestamp = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.timestamp(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteOnMessageCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMsg, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]

        sut.save(items) { _ in }

        XCTAssertEqual(store.receivedMsg, [.deletion])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let deletionError = anyNSError()

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMsg, [.deletion])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItems(), uniqueItems()]

        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMsg, [.deletion, .insert(item: items, timestamp: timestamp)])
    }

    func test_save_failedOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let deletionError = anyNSError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for save complete")

        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, deletionError)
    }

    func test_save_failedOnCacheInsertionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let insertError = anyNSError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for save complete")

        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, insertError)
    }

    // MARK: - Helper
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (localFeedLoader: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func uniqueItems() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any Error", code: 1)
    }
}
