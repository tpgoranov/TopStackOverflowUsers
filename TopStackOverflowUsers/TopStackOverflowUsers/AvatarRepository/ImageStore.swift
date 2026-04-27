//
//  ImageStore.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import Foundation
import CryptoKit

protocol ImageStoring {
    func imageData(for imageURLString: String) -> Data?
    func storeImageData(_ imageData: Data, for imageURLString: String) throws
    func removeImageData(for imageURLString: String) throws
}

final class ImageStore: ImageStoring {
    private let directoryURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directoryURL = applicationSupportURL.appendingPathComponent("TopUserAvatars", isDirectory: true)

        try? createDirectoryIfNeeded()
    }

    // Read image bytes from disk.
    func imageData(for imageURLString: String) -> Data? {
        let fileURL = fileURL(for: imageURLString)
        return try? Data(contentsOf: fileURL)
    }

    // Save image bytes to disk.
    func storeImageData(_ imageData: Data, for imageURLString: String) throws {
        try createDirectoryIfNeeded()
        let fileURL = fileURL(for: imageURLString)
        try imageData.write(to: fileURL, options: .atomic)
    }

    // Delete saved image bytes if the file is there.
    func removeImageData(for imageURLString: String) throws {
        let fileURL = fileURL(for: imageURLString)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    // Make the folder only one time.
    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    // Make a safe file path from the image url.
    private func fileURL(for imageURLString: String) -> URL {
        let fileName = "\(imageURLString.stableFileNameComponent).img"
        return directoryURL.appendingPathComponent(fileName, isDirectory: false)
    }
}

private extension String {
    // Turn a string into a stable file name.
    var stableFileNameComponent: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
