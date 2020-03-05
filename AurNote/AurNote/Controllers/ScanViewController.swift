//
//  ScanViewController.swift
//  AurNote
//
//  Created by Ayush Patel on 3/4/20.
//  Copyright © 2020 Ayush Patel. All rights reserved.
//

import Foundation
import WeScan

class ScanViewController: UIViewController, ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
         scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
         scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
         print(error)
    }
    
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        let scannerViewController = ImageScannerController(image: UIImage(named: "graph"), delegate: self)
        present(scannerViewController, animated: true)
    }

}
