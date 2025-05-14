//
//  RecipeRow.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//

import SwiftUI

struct RecipeRow: View {
    @ObservedObject var viewModel: RecipeViewModel
    
    let recipe: Recipe
    let imageSize: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let imageURL = recipe.photoUrlSmall {
                    ImageLoadingView(url: imageURL, size: imageSize)
                    
                } else {
                    Color.gray.frame(width: imageSize)
                }
                
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                    Text(recipe.cuisine)
                        .font(.subheadline)
                }
            }
            
            if let sourceUrl = recipe.sourceUrl, let url = URL(string: sourceUrl) {
                Link("View Recipe", destination: url)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                    .buttonStyle(.plain)
            }
            
            if let youtubeUrl = recipe.youtubeUrl, let url = URL(string: youtubeUrl) {
                Link("Watch Recipe on YouTube", destination: url)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                    .buttonStyle(.plain)
            }
        }
    }
}
