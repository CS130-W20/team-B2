////
////  Handwriting.swift
////  AurNote
////
////  Created by Kristi Richter on 2/20/20.
////  Copyright © 2020 Ayush Patel. All rights reserved.
//// Commented out bc it breaks the code bc the firebase ml kit doesnt fit in git, here for reference

import Foundation
import Firebase
import UIKit

/*
import Foundation
import Alamofire
class GoogleOCR{
    private let key = "be1532a6ebad19017481f7c3e0b189ab9e51cb14"
    var allText: [String: [Int]] = [:]
    private var apiURL: URL {
      return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(key)")!
    }
    
    func detect(from image: UIImage, completion: @escaping (OCRResult?) -> Void) {
      guard let base64Image = base64EncodeImage(image) else {
        print("Error while base64 encoding image")
        completion(nil)
        return
      }
      callGoogleVisionAPI(with: base64Image, completion: completion)
    }
    
    private func callGoogleVisionAPI(
      with base64EncodedImage: String,
      completion: @escaping (OCRResult?) -> Void) {
      let parameters: Parameters = [
        "requests": [
          [
            "image": [
              "content": base64EncodedImage
            ],
            "features": [
              [
                "type": "TEXT_DETECTION"
              ]
            ]
          ]
        ]
      ]
      let headers: HTTPHeaders = [
        "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",
        ]
      Alamofire.request(
        apiURL,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: headers)
        .responseData { response in // .responseData instead of .responseJSON
          if response.result.isFailure {
            completion(nil)
            return
          }
          guard let data = response.result.value else {
            completion(nil)
            return
          }
          // Decode the JSON data into a `GoogleCloudOCRResponse` object.
          let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
          completion(ocrResponse?.responses[0])
      }
    }

    private func base64EncodeImage(_ image: UIImage) -> String? {
      return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

*/


class HandwritingManager{
    //let vision = Vision.vision()
    private lazy var vision = Vision.vision()
    var allText: [String: [(String, String)]] = [:]
    //NSMutableDictionary* allTextNS = [NSMutableDictionary dictionary]
    //var allTextNS = [NSMutableDictionary()]
    //var allText: [String: [Int]] ()
    
    func processImage(uiImage: UIImage, className: String, fileName: String){
        let textRecognizer = vision.onDeviceTextRecognizer()
        //let uiImage = UIImage()
        let image = VisionImage(image: uiImage)
        textRecognizer.process(image) { result, error in
          guard error == nil, let result = result else {
            // ...
            return
          }

          //let resultText = result.text
            //print(resultText)
          for block in result.blocks {
              //let blockText = block.text
//              let blockConfidence = block.confidence
//              let blockLanguages = block.recognizedLanguages
//              let blockCornerPoints = block.cornerPoints
//              let blockFrame = block.frame
              for line in block.lines {
                  //let lineText = line.text
//                  let lineConfidence = line.confidence
//                  let lineLanguages = line.recognizedLanguages
//                  let lineCornerPoints = line.cornerPoints
//                  let lineFrame = line.frame
                  for element in line.elements {
                      let elementText = element.text //as NSString
                        //print(elementText, " !!")
                    if self.allText.keys.contains(elementText){
                        self.allText[elementText.lowercased()]?.append((className,fileName))
                    }
                    else{
                        self.allText[elementText.lowercased()] = [(className,fileName)]
                    }
                    print(self.allText)
                    //let array: NSArray = [pgNum]
                    //self.allTextNS[elementText] = array
                      
//                      let elementConfidence = element.confidence
//                      let elementLanguages = element.recognizedLanguages
//                      let elementCornerPoints = element.cornerPoints
//                      let elementFrame = element.frame
                  }
              }
          }
            //sorts the page numbers that the words appear on in increasing order
            for key in self.allText.keys{
                self.allText[key]?.sort(by:<)
            }
        }
    }
}

