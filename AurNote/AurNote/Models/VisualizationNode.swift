/*
Abstract:
A SceneKit node that fades between two images.
*/

import Foundation
import SceneKit
import ARKit

class VisualizationNode: SCNNode {

    /// The images to fade between.
    /// - Tag: VisualizationNode
    private let currentImage: SCNNode

    /// The duration of the fade animation, in seconds.
    private let fadeDuration = 1.0
    /**
     Create a plane geometry for the current and previous altered images sized to the argument
     size, and initialize them with transparent material. Because `SCNPlane` is defined in the
     XY-plane, but `ARImageAnchor` is defined in the XZ plane, you rotate by 90 degrees to match.
     */
    init(_ size: CGSize) {
        currentImage = createPlaneNode(size: size, rotation: -.pi / 2, contents: UIColor.clear)
        super.init()
        
        addChildNode(currentImage)
    }
    
    /// Assigns a new current image and fades from the previous image to it.
    /// - Tag: ImageFade
    /// - Parameter alteredImage: image to display in the node
    func display(_ alteredImage: CGImage) {
        
        currentImage.geometry?.firstMaterial?.diffuse.contents = alteredImage
        
        currentImage.opacity = 0.0
        
        // Fade between the two images.
        SCNTransaction.begin()
        SCNTransaction.animationDuration = fadeDuration
        currentImage.opacity = 1.0
        SCNTransaction.commit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

