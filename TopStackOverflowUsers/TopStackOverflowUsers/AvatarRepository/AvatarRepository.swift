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
    private let networkClient: NetworkRequestPerforming
    private let memoryCache = NSCache<NSString, UIImage>()

    init(
        networkClient: NetworkRequestPerforming = AppNetworkClient()
    ) {
        self.networkClient = networkClient
        memoryCache.countLimit = 20
    }

    func cachedImage(for imageURLString: String) -> UIImage? {
        if let image = memoryCache.object(forKey: imageURLString as NSString) {
            return image
        }
        
        return nil
    }

    func fetchImage(for imageURLString: String) async throws -> UIImage? {
        if let image = cachedImage(for: imageURLString) {
            return image
        }

        let imageData = try await networkClient.performDataRequest(
            StackOverflowDownloadImageEndpoint(imageURLString: imageURLString)
        )
        let image = UIImage(data: imageData)
        if let image {
            memoryCache.setObject(image, forKey: imageURLString as NSString)
        }
        return image
    }
}
