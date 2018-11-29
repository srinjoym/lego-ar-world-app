//
//  ViewController.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 11/23/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        sceneView.automaticallyUpdatesLighting = true
        
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        // The 3D cube geometry we want to draw
        let boxGeometry = SCNBox(width:0.1, height:0.1, length:0.1, chamferRadius:0.0)
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3Make(0, 0, -0.5)
        
        scene.rootNode.addChildNode(boxNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
//        let referenceObject = ARReferenceObject(archiveURL: URL("art.scnassets/Scan_18-25-43.arobject"))
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Gallery", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
//        configuration.detectionObjects = [referenceObject]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
//     Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (anchor.name == "Layer1") {
            guard let objectAnchor = anchor as? ARObjectAnchor else { return }
//            objectAnchor.referenceObject.
//            let width = CGFloat(objectAnchor.extent.x)
//            let height = CGFloat(objectAnchor.extent.z)
//            let plane = SCNPlane(width: width, height: height)
            
//            let planeNode = SCNNode(geometry: plane)
            
            let x = CGFloat(objectAnchor.referenceObject.center.x)
            let y = CGFloat(objectAnchor.referenceObject.center.y)
            let z = CGFloat(objectAnchor.referenceObject.center.z)
            
            
            let brickScene = SCNScene(named: "art.scnassets/brick.scn")
            guard let brickNode = brickScene?.rootNode else { return }
            
            let brickHeight = CGFloat(brickNode.boundingBox.min.x)
            
            let brickWidth = CGFloat((brickNode.boundingBox.min.y))
            brickNode.position = SCNVector3(x + brickHeight/2, y, z)
            
            //        brickNode.eulerAngles.x = -.pi / 2
            
            //        node.addChildNode(planeNode)
            node.addChildNode(brickNode)
            let brickNode2 = brickNode.clone()
            brickNode2.position = SCNVector3(x + brickHeight/2, y + brickWidth*2, z )
            node.addChildNode(brickNode2)
            
        }
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        let brickScene = SCNScene(named: "art.scnassets/brick.scn")
//        guard let brickNode = brickScene?.rootNode else { return }
//
//        if let objectAnchor = anchor as? ARObjectAnchor {
//            node.addChildNode(brickNode)
//        }
//    }
//
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
