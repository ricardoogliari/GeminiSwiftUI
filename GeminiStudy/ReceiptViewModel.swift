//
//  ReceiptViewModel.swift
//  GeminiStudy
//
//  Created by Ricardo on 14/06/24.
//

import Foundation
import GoogleGenerativeAI
import PhotosUI

class ReceiptViewModel: ObservableObject {
    @Published var status: UiModel = UiModel.initial
    var image: UIImage?
    
    func setSelectedPhoto(newPhoto: UIImage?){
        image = newPhoto;
        status = UiModel.onlyPhoto
    }
    
    func getKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
        else {
          fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") {
          fatalError(
            "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
          )
        }
        return value
    }
    
    func gemini(command: String) async {
        status = UiModel.loading
        let config = GenerationConfig(
          temperature: 0.9,
          topP: 0.95,
          topK: 64,
          maxOutputTokens: 1024,
          responseMIMEType: "text/plain"
        )
        
        let model = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: getKey(),
            generationConfig: config)
        
        var images = [any ThrowingPartsRepresentable]()
        images.append(image!)
        do {
            let response = try await model.generateContent(
                command, images
            )
            if let text = response.text {
                status = UiModel.success(text)
                print(text)
            }
        } catch {
            status = UiModel.error("GenerateContentError")
        }
    }
    
    func reset() {
        status = UiModel.initial
    }
}
