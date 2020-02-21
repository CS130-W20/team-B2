/*
Abstract:
An object that augments a rectangular shape that exists in the physical environment.
*/

import Foundation
import ARKit
import CoreML

/// - Tag: AlteredImage
class AlteredImage {

    let referenceImage: ARReferenceImage
    
    /// A handle to the anchor ARKit assigned the tracked image.
    private(set) var anchor: ARImageAnchor?
    
    /// A SceneKit node that animates images of varying style.
    private let visualizationNode: VisualizationNode
    
    /// Stores a reference to the Core ML output image.
    /// A timer that effects a grace period before checking
    ///  for a new rectangular shape in the user's environment.
    private var failedTrackingTimeout: Timer?
    
    /// The timeout in seconds after which the `imageTrackingLost` delegate is called.
    private var timeout: TimeInterval = 1.0
    
    /// A delegate to tell when image tracking fails.
    weak var delegate: AlteredImageDelegate?
    
    init?(_ image: CIImage, referenceImage: ARReferenceImage) {
        
        self.referenceImage = referenceImage
        visualizationNode = VisualizationNode(referenceImage.physicalSize)
                
        // Start the failed tracking timer right away. This ensures that the app starts
        //  looking for a different image to track if this one isn't trackable.
        resetImageTrackingTimeout()
        
        createAlteredImage()
    }
    
    deinit {
        visualizationNode.removeAllAnimations()
        visualizationNode.removeFromParentNode()
    }
    
    /// Displays the altered image using the anchor and node provided by ARKit.
    /// - Tag: AddVisualizationNode
    /// - Parameters:
    ///   - anchor: augmented reality anchor
    ///   - node: scene node
    func add(_ anchor: ARAnchor, node: SCNNode) {
        if let imageAnchor = anchor as? ARImageAnchor, imageAnchor.referenceImage == referenceImage {
            self.anchor = imageAnchor
            
            // Start the image tracking timeout.
            resetImageTrackingTimeout()
            
            // Add the node that displays the altered image to the node graph.
            node.addChildNode(visualizationNode)

        }
    }
    
    /**
     If an image the app was tracking is no longer tracked for a given amount of time, invalidate
     the current image tracking session. This, in turn, enables Vision to start looking for a new
     rectangular shape in the camera feed.
     - Tag: AnchorWasUpdated
     - Parameter anchor: anchor to update to
     */
    func update(_ anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor, self.anchor == anchor {
            self.anchor = imageAnchor
            // Reset the timeout if the app is still tracking an image.
            if imageAnchor.isTracked {
                resetImageTrackingTimeout()
            }
        }
    }
    
    
    /// Prevents the image tracking timeout from expiring.
    private func resetImageTrackingTimeout() {
        failedTrackingTimeout?.invalidate()
        failedTrackingTimeout = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            if let strongSelf = self {
                self?.delegate?.alteredImageLostTracking(strongSelf)
            }
        }
    }
    
    /// Alters the image's appearance by applying the "StyleTransfer" Core ML model to it.
    /// - Tag: CreateAlteredImage
    func createAlteredImage() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let image = UIImage(named: "graph")?.cgImage
            self.visualizationNode.display(image!)
        }
    }
    
}

/**
 Tells a delegate when image tracking failed.
  In this case, the delegate is the view controller.
 */
protocol AlteredImageDelegate: class {
    func alteredImageLostTracking(_ alteredImage: AlteredImage)
}
