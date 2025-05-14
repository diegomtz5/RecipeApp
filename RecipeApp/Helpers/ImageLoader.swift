//
//  ImageLoader.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//

import Foundation
import SwiftUI

enum ImageLoaderError: Error {
    case invalidURL
    case badResponse
    case unknownError
    case networkError(Error)
}

class ImageLoader: ObservableObject {
    let url: String?
    
    @Published var image: UIImage? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(url: String?) {
        self.url = url
    }
    
    func fetch() async {
        guard image == nil && !isLoading else {
            return
        }
        
        guard let url = url, let fetchURL = URL(string: url) else {
            await MainActor.run {
                self.handleError(.invalidURL)
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        if let cachedImage = getCachedImage(for: fetchURL) {
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        do {
            
            let (data, response) = try await URLSession.shared.data(from: fetchURL)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                await MainActor.run {
                    self.handleError(.badResponse)
                }
            } else if let image = UIImage(data: data) {
                cacheImage(image, for: fetchURL)
                
                await MainActor.run {
                    self.image = image
                }
            } else {
                await MainActor.run {
                    self.handleError(.unknownError)
                }
            }
        } catch let networkError {
            await MainActor.run {
                self.handleError(.networkError(networkError))
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    private func handleError(_ error: ImageLoaderError) {
        switch error {
        case .invalidURL:
            self.errorMessage = "Invalid URL"
        case .badResponse:
            self.errorMessage = "Received a bad response from the server"
        case .unknownError:
            self.errorMessage = "An unknown error occurred"
        case .networkError(let networkError):
            self.errorMessage = "Network error: \(networkError.localizedDescription)"
        }
    }

    private func cacheImage(_ image: UIImage, for url: URL) {
        if let imageData = image.pngData() {
            let cache = URLCache.shared
            let request = URLRequest(url: url)
            let cachedResponse = CachedURLResponse(response: URLResponse(url: url, mimeType: "image/png", expectedContentLength: imageData.count, textEncodingName: nil), data: imageData)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
    }

    func getCachedImage(for url: URL) -> UIImage? {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }
}
