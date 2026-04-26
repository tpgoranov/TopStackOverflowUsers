//
//  AvatarRepositoryTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import UIKit
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class AvatarRepositoryTests: XCTestCase {
    func testNoImageReturned() {
        let imageStore = MockImageStore()
        let networkClient = MockNetworkClient()
        let repository = AvatarRepository(imageStore: imageStore, networkClient: networkClient)

        let image = repository.cachedImage(for: "https://example.com/missing.png")

        XCTAssertNil(image)
    }

    func testReturnStoredImage() throws {
        let imageURLString = "https://example.com/avatar.png"
        let imageData = try XCTUnwrap(makeRealImageData())
        let imageStore = MockImageStore(storedDataByURL: [imageURLString: imageData])
        let networkClient = MockNetworkClient()
        let repository = AvatarRepository(imageStore: imageStore, networkClient: networkClient)

        let firstImage = repository.cachedImage(for: imageURLString)
        let secondImage = repository.cachedImage(for: imageURLString)

        XCTAssertNotNil(firstImage)
        XCTAssertNotNil(secondImage)
    }

    func testFetchAndStoreImage() async throws {
        let imageURLString = "https://example.com/avatar.png"
        let imageData = try XCTUnwrap(makeRealImageData())
        let imageStore = MockImageStore(storedDataByURL: [imageURLString: imageData])
        let networkClient = MockNetworkClient()
        let repository = AvatarRepository(imageStore: imageStore, networkClient: networkClient)

        let image = try await repository.fetchImage(for: imageURLString)

        XCTAssertNotNil(image)
        XCTAssertEqual(networkClient.performDataRequestCallCount, 0)
        XCTAssertEqual(imageStore.storedDataByURL[imageURLString], imageData)
    }

    private func makeRealImageData() -> Data? {
        Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9p2g8S8AAAAASUVORK5CYII=")
    }
}

private final class MockImageStore: ImageStoring {
    private(set) var storedDataByURL: [String: Data]

    init(storedDataByURL: [String: Data] = [:]) {
        self.storedDataByURL = storedDataByURL
    }

    func imageData(for imageURLString: String) -> Data? {
        return storedDataByURL[imageURLString]
    }

    func storeImageData(_ imageData: Data, for imageURLString: String) throws {
        storedDataByURL[imageURLString] = imageData
    }

    func removeImageData(for imageURLString: String) throws {
        storedDataByURL[imageURLString] = nil
    }
}

private final class MockNetworkClient: NetworkRequestPerforming {
    let responseData: Data?
    private(set) var performDataRequestCallCount = 0

    init(responseData: Data? = nil) {
        self.responseData = responseData
    }

    func performRequest<T>(_ endpoint: any Endpoint) async throws -> T where T: Decodable {
        fatalError("it is not used in AvatarRepository tests")
    }

    func performDataRequest(_ endpoint: any Endpoint) async throws -> Data {
        performDataRequestCallCount += 1
        return responseData ?? Data()
    }
}

private enum MockAvatarRepositoryError: Error, Equatable {
    case downloadFailed
}
