//
//  ImageStoreTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import Foundation
import XCTest
@testable import TopStackOverflowUsers

final class ImageStoreTests: XCTestCase {
    private let missingImageURLString = "https://example.com/missing-image.png"
    private let persistedImageURLString = "https://example.com/persisted-image.png"
    private let sharedImageURLString = "https://example.com/shared-image.png"

    override func tearDownWithError() throws {
        let imageStore = ImageStore()
        try imageStore.removeImageData(for: missingImageURLString)
        try imageStore.removeImageData(for: persistedImageURLString)
        try imageStore.removeImageData(for: sharedImageURLString)
        try super.tearDownWithError()
    }

    func testMissingImageData() {
        let imageStore = ImageStore()
        try? imageStore.removeImageData(for: missingImageURLString)

        let imageData = imageStore.imageData(for: missingImageURLString)

        XCTAssertNil(imageData)
    }

    func testStoreImageData() throws {
        let expectedData = Data([0x01, 0x02, 0x03, 0x04])
        let imageStore = ImageStore()

        try imageStore.storeImageData(expectedData, for: persistedImageURLString)

        XCTAssertEqual(imageStore.imageData(for: persistedImageURLString), expectedData)
    }

    func testRemoveImageData() throws {
        let imageStore = ImageStore()
        let expectedData = Data([0x0D, 0x0E, 0x0F])

        try imageStore.storeImageData(expectedData, for: persistedImageURLString)
        XCTAssertEqual(imageStore.imageData(for: persistedImageURLString), expectedData)

        try imageStore.removeImageData(for: persistedImageURLString)

        XCTAssertNil(imageStore.imageData(for: persistedImageURLString))
    }
}
