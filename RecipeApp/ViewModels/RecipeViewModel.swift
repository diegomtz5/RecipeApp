//
//  RecipeViewModel.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//

import Foundation

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var displayAlert: Bool = false
    @Published var searchQuery: String = "" 

    private let recipeService = RecipeService()
    
    var filteredRecipes: [Recipe] {
        if searchQuery.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.lowercased().contains(searchQuery.lowercased()) ||
                recipe.cuisine.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
    
    func fetchRecipes() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let fetchedRecipes = try await recipeService.fetchRecipes()
            await MainActor.run {
                self.recipes = fetchedRecipes
            }
        } catch let error as RecipeServiceError {
            await MainActor.run {
                self.handleError(error)
            }
        } catch {
            await MainActor.run {
                self.error = "Unexpected error occurred: \(error.localizedDescription)"
                self.displayAlert = true
                self.recipes = []
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    private func handleError(_ error: RecipeServiceError) {
        switch error {
        case .malformedData:
            self.error = "The data is malformed. Please try again later."
        case .networkError(let networkError):
            self.error = "Network error: \(networkError.localizedDescription)"
        case .decodingError(let decodingError):
            self.error = "Decoding error: \(decodingError.localizedDescription)"
        case .emptyData:
            self.error = "No recipes found."
        }
        
        self.displayAlert = true
        self.recipes = [] 
    }
}

