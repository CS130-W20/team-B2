/*
Abstract:
A view controller that recognizes and tracks images found in the user's environment.
*/

import ARKit
import Foundation
import SceneKit
import UIKit

class ARAnnotationViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBAction func didCapture(_ sender: Any) {
        let image = sceneView.snapshot()
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    static var instance: ARAnnotationViewController?
    
    /// An object that detects rectangular shapes in the user's environment.
    let rectangleDetector = RectangleDetector()
    
    /// An object that represents an augmented image that exists in the user's environment.
    var alteredImage: AlteredImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rectangleDetector.delegate = self
        sceneView.delegate = self
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        ARAnnotationViewController.instance = self
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
        
        searchForNewImageToTrack()
	}
    /// Searches for a new image to track when previous image is nothing is currently being tracked
    func searchForNewImageToTrack() {
        alteredImage?.delegate = nil
        alteredImage = nil
        
        // Restart the session and remove any image anchors that may have been detected previously.
        runImageTrackingSession(with: [], runOptions: [.removeExistingAnchors, .resetTracking])
        
        showMessage("Look for a rectangular image.", autoHide: false)
    }
    
    /// Runs image tracking session
    /// - Parameters:
    ///   - trackingImages: A set of AR Reference images to track
    ///   - runOptions: Options for the AR session
    private func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                         runOptions: ARSession.RunOptions = [.removeExistingAnchors]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 1
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration, options: runOptions)
    }
    
    // The timer for message presentation.
    private var messageHideTimer: Timer?
    /// Shows message on screen when rectangle is not found
    /// - Parameters:
    ///   - message: The message to display
    ///   - autoHide: by default message is hidden
    func showMessage(_ message: String, autoHide: Bool = true) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
            self.setMessageHidden(false)
            
            self.messageHideTimer?.invalidate()
            if autoHide {
                self.messageHideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                    self?.setMessageHidden(true)
                }
            }
        }
    }
    /// Set message as hidden
    /// - Parameter hide: boolean
    private func setMessageHidden(_ hide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
                self.messagePanel.alpha = hide ? 0 : 1
            })
        }
    }
    
    /// Handles tap gesture input.
    @IBAction func didTap(_ sender: Any) {
    }
}

extension ARAnnotationViewController: ARSCNViewDelegate {
    
    /// - Tag: ImageWasRecognized
    /// Adds image to node tree so that it can be rendered, sets message to be hidden as rectangle is found
    /// - Parameters:
    ///   - renderer: scene renderer
    ///   - node: scene node to add anchor
    ///   - anchor: ar anchor for the image that should be added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        alteredImage?.add(anchor, node: node)
        setMessageHidden(true)
    }

    /// - Tag: DidUpdateAnchor
    /// To update anchor when image is moved
    /// - Parameters:
    ///   - renderer: scene renderer
    ///   - node: scene node to add anchor
    ///   - anchor: ar anchor for the image that should be added
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        alteredImage?.update(anchor)
    }
    
    /// When errors in session
    /// - Parameters:
    ///   - session: AR session
    ///   - error: The error
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        if arError.code == .invalidReferenceImage {
            // Restart the experience, as otherwise the AR session remains stopped.
            // There's no benefit in surfacing this error to the user.
            print("Error: The detected rectangle cannot be tracked.")
            searchForNewImageToTrack()
            return
        }
        
        let errorWithInfo = arError as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `compactMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            
            // Present an alert informing about the error that just occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.searchForNewImageToTrack()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ARAnnotationViewController: RectangleDetectorDelegate {
    /// Called when the app recognized a rectangular shape in the user's environment.
    /// - Tag: CreateReferenceImage
    /// - Parameter rectangleContent: the image corresponding to the content within rectangle detected
    func rectangleFound(rectangleContent: CIImage) {
        DispatchQueue.main.async {
            
            // Ignore detected rectangles if the app is currently tracking an image.
            guard self.alteredImage == nil else {
                return
            }
            
            guard let referenceImagePixelBuffer = rectangleContent.toPixelBuffer(pixelFormat: kCVPixelFormatType_32BGRA) else {
                print("Error: Could not convert rectangle content into an ARReferenceImage.")
                return
            }
            
            let possibleReferenceImage = ARReferenceImage(referenceImagePixelBuffer, orientation: .up, physicalWidth: CGFloat(0.5))
            
            possibleReferenceImage.validate { [weak self] (error) in
                if let error = error {
                    print("Reference image validation failed: \(error.localizedDescription)")
                    return
                }

                // Try tracking the image that lies within the rectangle which the app just detected.
                guard let newAlteredImage = AlteredImage(rectangleContent, referenceImage: possibleReferenceImage) else { return }
                newAlteredImage.delegate = self
                self?.alteredImage = newAlteredImage
                
                // Start the session with the newly recognized image.
                self?.runImageTrackingSession(with: [newAlteredImage.referenceImage])
            }
        }
    }
}

/// Enables the app to create a new image from any rectangular shapes that may exist in the user's environment.
extension ARAnnotationViewController: AlteredImageDelegate {
    /// When tracking is lost, so that a new image is tracked
    /// - Parameter alteredImage: the image that is no longer being tracked
    func alteredImageLostTracking(_ alteredImage: AlteredImage) {
        searchForNewImageToTrack()
    }
}
