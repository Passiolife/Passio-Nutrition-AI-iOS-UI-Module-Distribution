//
//  ImageLoggingService.swift
//  
//
//  Created by Nikunj Prajapati on 19/06/24.
//

import UIKit

protocol ImageLoggingService: AnyObject {
    func fetchFoodData(
        for images: [UIImage],
        recognitionModel: @escaping ([PassioSpeechRecognitionModel]) -> Void
    )
}

extension ImageLoggingService {

    func fetchFoodData(
        for images: [UIImage],
        recognitionModel: @escaping ([PassioSpeechRecognitionModel]) -> Void
    ) {

        var recognitionData: [PassioSpeechRecognitionModel] = []
        let dispatchGroup = DispatchGroup()

        images.forEach { image in

            dispatchGroup.enter()

            PassioNutritionAI.shared.recognizeImageRemote(image: image) { (passioAdvisorFoodInfo) in
                passioAdvisorFoodInfo.forEach {
                    let model = PassioSpeechRecognitionModel(action: nil,
                                                             meal: PassioMealTime.currentMealTime(),
                                                             date: nil,
                                                             extractedIngridient: $0)
                    recognitionData.append(model)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            recognitionModel(recognitionData)
        }
    }
}
