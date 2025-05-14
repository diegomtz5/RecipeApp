//
//  RecipeService.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//
import Foundation



enum RecipeServiceError: Error, Equatable {
    case malformedData
    case networkError(Error)
    case decodingError(Error)
    case emptyData

    static func ==(lhs: RecipeServiceError, rhs: RecipeServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.malformedData, .malformedData),
             (.emptyData, .emptyData):
            return true
            
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        default:
            return false
        }
    }
}


class RecipeService {
    private let recipesUrl: URL

    init(url: URL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!) {
        self.recipesUrl = url
    }

    func fetchRecipes() async throws -> [Recipe] {
         do {
             let (data, _) = try await URLSession.shared.data(from: recipesUrl)
             
             let decodedResponse = try JSONDecoder().decode([String: [Recipe]].self, from: data)
             
             guard let recipes = decodedResponse["recipes"] else {
                 throw RecipeServiceError.malformedData
             }
             return recipes
         } catch let error as DecodingError {
             throw RecipeServiceError.malformedData
         } catch {
             throw RecipeServiceError.networkError(error)
         }
     }
}
