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

class MainViewController: UIViewController {

    let session =  ARSession()
    var sessionConfig: ARConfiguration = ARWorldTrackingConfiguration()

    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restartPlaneDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func restartPlaneDetection() {
        // configure session
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
            worldSessionConfig.planeDetection = .horizontal
            configureDetectionObjects(sessionConfig: worldSessionConfig)
            
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func configureDetectionObjects(sessionConfig: ARWorldTrackingConfiguration) {
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Gallery", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        sessionConfig.detectionObjects = referenceObjects
    }
    
    
    @IBAction func displaySettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(
            withIdentifier: "settingsViewController") as? SettingsViewController else {
                return
        }
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Options"
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = self
        navigationController.preferredContentSize = CGSize(width: sceneView.bounds.size.width - 20,
                                                           height: sceneView.bounds.size.height - 50)
        self.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = settingsButton
        navigationController.popoverPresentationController?.sourceRect = settingsButton.bounds
    }
    
    @objc
    func dismissSettings() {
        self.dismiss(animated: true, completion: nil)
//        updateSettings()
    }
}

// MARK: - ARKit / ARSCNView
extension MainViewController {
    func setupScene() {
        sceneView.setUp(viewController: self, session: session)
//        DispatchQueue.main.async {
//            self.screenCenter = self.sceneView.bounds.mid
//        }
    }
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    
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

// MARK: - UIPopoverPresentationControllerDelegate
extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        updateSettings()
    }
}
