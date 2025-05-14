//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//


import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeViewModel()
    @FocusState var isFocused
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.recipes.isEmpty {
                    VStack{
                        Text("No recipes available")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                        Button(action: {
                            Task {
                                await viewModel.fetchRecipes() 
                            }
                        }) {
                            Text("Reload")
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                } else {
                    TextField("Search recipes...", text: $viewModel.searchQuery)
                             .padding(8)
                             .background(Color.gray.opacity(0.1))
                             .cornerRadius(10)
                             .padding([.leading, .trailing], 16)
                             .focused($isFocused)
                                
                    List(viewModel.filteredRecipes) { recipe in
                        RecipeRow(viewModel: viewModel, recipe: recipe)
                    }
                    .listStyle(.plain)
                }
            }
            .onTapGesture {
                isFocused = false
            }
            .navigationTitle("Recipes")
            .onAppear {
                URLCache.shared.memoryCapacity = 1024 * 1024 * 512
                Task {
                    await viewModel.fetchRecipes()
                }
            }
            .refreshable {
                Task {
                    await viewModel.fetchRecipes()
                }
            }
            .alert(isPresented: $viewModel.displayAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.error ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
}
