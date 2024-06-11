//
//  ContentView.swift
//  GeminiStudy
//
//  Created by Ricardo on 11/06/24.
//

import SwiftUI
import PhotosUI
import Combine

struct ContentView: View {
    @StateObject var viewModel = ReceiptViewModel()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var command: String = "Identifique com precisão o produto assado na imagem e forneça uma receita apropriada e consistente com sua análise."
    
    var body: some View {
        switch viewModel.status {
            case .initial:
                getInitialStateView()
            case .loading:
                Text("Waiting.. loading the results!")
            case .onlyPhoto:
                getOnlyPhotoView()
            case .success(let message):
                getSuccessView(result: message)
            case .error(let message):
                Text(message)
        }
    }
    
    func getSuccessView(result: String) -> some View {
        return VStack {
            Text(result).padding(.bottom, 20)
            Button (
                action: {
                    Task {
                        viewModel.reset()
                    }
                }, label: {
                    Text("New receipt")
                }
            )
        }.padding(20)
    }
    
    func getOnlyPhotoView() -> some View {
        return VStack {
            Image(uiImage: viewModel.image!)
                .resizable()
                .scaledToFit()
            TextField(
                "Username",
                text: $command,
                axis: .vertical
            )
            Button (
                action: {
                    Task {
                        await viewModel.gemini(command: command.self)
                    }
                }, label: {
                    Text("Go")
                }
            )
        }.padding(20)
    }
    
    func getInitialStateView() -> some View {
        return PhotosPicker(
            "Select an image",
            selection: $selectedItem,
            matching: .images)
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        var image: UIImage? = UIImage(data: data)
                        viewModel.setSelectedPhoto(newPhoto: image)
                    }
                }
            }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
