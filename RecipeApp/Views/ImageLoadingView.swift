//
//  ImageLoadingView.swift
//  RecipeApp
//
//  Created by Diego Martinez on 5/14/25.
//

import SwiftUI

struct ImageLoadingView: View {
    @StateObject var imageLoader: ImageLoader
    
    let size: CGFloat
    
    init(url:String?, size: CGFloat){
        self._imageLoader = StateObject(wrappedValue: ImageLoader(url: url))
        self.size = size
    }
    
    var body: some View{
        Group{
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
            }else if let errorMessage = imageLoader.errorMessage {
                Text(errorMessage)
                    .frame(width: size, height: size)
            }else{
                ProgressView()
                    .frame(width: size, height: size)
            }
        }
        .onAppear{
            Task {
                await imageLoader.fetch()
            }
        }
    }
}
