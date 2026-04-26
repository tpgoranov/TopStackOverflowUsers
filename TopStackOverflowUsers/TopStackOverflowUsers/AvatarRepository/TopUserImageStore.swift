//
//  TopUserImageStore.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import Foundation
import CryptoKit

protocol TopUserImageStoring {
    func imageData(for imageURLString: String) -> Data?
    func storeImageData(_ imageData: Data, for imageURLString: String) throws
}

final class TopUserImageStore: TopUserImageStoring {
    private let directoryURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let applicationSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directoryURL = applicationSupportURL.appendingPathComponent("TopUserAvatars", isDirectory: true)

        try? createDirectoryIfNeeded()
    }

    func imageData(for imageURLString: String) -> Data? {
        let fileURL = fileURL(for: imageURLString)
        return try? Data(contentsOf: fileURL)
    }

    func storeImageData(_ imageData: Data, for imageURLString: String) throws {
        try createDirectoryIfNeeded()
        let fileURL = fileURL(for: imageURLString)
        try imageData.write(to: fileURL, options: .atomic)
    }

    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    private func fileURL(for imageURLString: String) -> URL {
        let fileName = "\(imageURLString.stableFileNameComponent).img"
        return directoryURL.appendingPathComponent(fileName, isDirectory: false)
    }
}

private extension String {
    var stableFileNameComponent: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
