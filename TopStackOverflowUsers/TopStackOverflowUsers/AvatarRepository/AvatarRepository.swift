//
//  AvatarRepository.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit

protocol AvatarRepositorying {
    func cachedImage(for imageURLString: String) -> UIImage?
    func fetchImage(for imageURLString: String) async throws -> UIImage?
}

final class AvatarRepository: AvatarRepositorying {
    private let imageStore: ImageStoring
    private let networkClient: NetworkRequestPerforming
    private let memoryCache = NSCache<NSString, UIImage>()

    init(
        imageStore: ImageStoring = ImageStore(),
        networkClient: NetworkRequestPerforming = AppNetworkClient()
    ) {
        memoryCache.countLimit = 20
        self.imageStore = imageStore
        self.networkClient = networkClient
    }

    // First try to get the image from cache.
    func cachedImage(for imageURLString: String) -> UIImage? {
        if let image = memoryCache.object(forKey: imageURLString as NSString) {
            return image
        }

        guard
            let imageData = imageStore.imageData(for: imageURLString),
            let image = UIImage(data: imageData)
        else {
            return nil
        }

        memoryCache.setObject(image, forKey: imageURLString as NSString)
        return image
    }

    // Download the image if it is not already saved.
    func fetchImage(for imageURLString: String) async throws -> UIImage? {
        if let image = cachedImage(for: imageURLString) {
            return image
        }

        let imageData = try await networkClient.performDataRequest(
            StackOverflowDownloadImageEndpoint(imageURLString: imageURLString)
        )
        try imageStore.storeImageData(imageData, for: imageURLString)

        guard let image = UIImage(data: imageData) else {
            return nil
        }

        memoryCache.setObject(image, forKey: imageURLString as NSString)
        return image
    }
}
