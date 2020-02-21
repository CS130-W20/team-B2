//
//  Handwriting.swift
//  AurNote
//
//  Created by Kristi Richter on 2/20/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class HandwritingManager{
    //let vision = Vision.vision()
    private lazy var vision = Vision.vision()
    var allText: [String: [Int]] = [:]
    //var allText: [String: [Int]] ()
    func processImage(in uiImage: UIImage, pgNum: Int){
        let textRecognizer = vision.onDeviceTextRecognizer()
        //let uiImage = UIImage()
        let image = VisionImage(image: uiImage)
        textRecognizer.process(image) { result, error in
          guard error == nil, let result = result else {
            // ...
            return
          }

          let resultText = result.text
          for block in result.blocks {
              let blockText = block.text
//              let blockConfidence = block.confidence
//              let blockLanguages = block.recognizedLanguages
//              let blockCornerPoints = block.cornerPoints
//              let blockFrame = block.frame
              for line in block.lines {
                  let lineText = line.text
//                  let lineConfidence = line.confidence
//                  let lineLanguages = line.recognizedLanguages
//                  let lineCornerPoints = line.cornerPoints
//                  let lineFrame = line.frame
                  for element in line.elements {
                      let elementText = element.text
                      self.allText[elementText]?.append(pgNum)
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

