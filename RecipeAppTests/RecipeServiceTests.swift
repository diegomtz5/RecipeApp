//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by Diego Martinez on 5/5/25.
//
import XCTest
@testable import RecipeApp

class RecipeServiceTests: XCTestCase {
    
    
    func testFetchRecipesSuccess() async {
        let recipeService = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!)
        
        do {
            let recipes = try await recipeService.fetchRecipes()
            XCTAssertTrue(!recipes.isEmpty, "Expected a non empty array of recipes")
        } catch {
            XCTFail("Expected success, but got error: \(error)")
        }
    }
    func testFetchRecipesEmpty() async {
        let recipeService = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!)
        
        do {
            let recipes = try await recipeService.fetchRecipes()
            XCTAssertTrue(recipes.isEmpty, "Expected an empty array, but got: \(recipes).")

        } catch {
            XCTFail("Expected empty data, but got error: \(error)")

        }
    }
    func testFetchRecipesMalformed() async {
        let recipeService = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!)
        
        do {
            let recipes = try await recipeService.fetchRecipes()
            
            XCTFail("Expected error, but request succeeded with recipes: \(recipes)")
        } catch let error {
            guard let recipeServiceError = error as? RecipeServiceError else {
                XCTFail("This is the wrong type of error")
                return
            }
            
            XCTAssertEqual(recipeServiceError, RecipeServiceError.malformedData, "Expected malformedData, but got: \(recipeServiceError)")
        }
    }
}
