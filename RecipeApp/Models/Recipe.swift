//
//  Recipe.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//

struct Recipe: Codable, Identifiable {
    var uuid: String
    var name: String
    var cuisine: String
    var photoUrlLarge: String?
    var photoUrlSmall: String?
    var sourceUrl: String?
    var youtubeUrl: String?
    
    var id: String {
        return uuid
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case name
        case cuisine
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}
