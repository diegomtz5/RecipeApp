//
//  ImageLoaderTests.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//
import XCTest
@testable import RecipeApp

class ImageLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        URLCache.shared.removeAllCachedResponses()
    }

    func testImageCaching() async {
        let imageURL = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dce36ed7-d5bd-4532-9e9f-fafd75a4eb8f/small.jpg"
        let imageLoader = ImageLoader(url: imageURL)
        
        await imageLoader.fetch()
        
        XCTAssertNotNil(imageLoader.image, "Image should be loaded from network during first fetch")
        
        guard let cachedImage = imageLoader.getCachedImage(for: URL(string: imageURL)!) else {
            XCTFail("Image should be cached after the first fetch")
            return
        }
        
        XCTAssertEqual(imageLoader.image?.pngData(), cachedImage.pngData(), "The cached image should match the fetched image")
        
        await imageLoader.fetch()
        
        XCTAssertNotNil(imageLoader.image, "Image should still be available after second fetch from cache")
    }
    
    func testImageCachingNotFetched() async {
        let imageURL = "kjbkj"
        let imageLoader = ImageLoader(url: imageURL)
        
        await imageLoader.fetch()
        
        XCTAssertNotNil(imageLoader.errorMessage, "Error message should be set")
        
        if let errorMessage = imageLoader.errorMessage {
            XCTAssertTrue(errorMessage.contains("Network error"), "Expected network error, but got: \(errorMessage)")
        } else {
            XCTFail("Error message was not set")
        }
        
        XCTAssertNil(imageLoader.image, "Image should not be available if the fetch fails")
    }
}
