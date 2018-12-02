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

    var currentLegoScene: LegoScene?
    let session =  ARSession()
    var sessionConfig: ARConfiguration = ARWorldTrackingConfiguration()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.setUp(viewController: self, session: session)
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
            configureDetectionObjects(sessionConfig: worldSessionConfig, groupName: "LegoModels_1")
            
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func configureDetectionObjects(sessionConfig: ARWorldTrackingConfiguration, groupName: String) {
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: groupName, bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        sessionConfig.detectionObjects = referenceObjects
    }
    
    // MARK: - Settings
    @IBOutlet weak var settingsButton: UIButton!
    
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
    
    // MARK: - Planes
    
    var planes = [ARPlaneAnchor: Plane]()
    
    func displayPlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        DispatchQueue.main.async {
//            self.messageBox.text = "Plane Detected!"
//        }
        let planeNode = Plane(planeAnchor)
        planes[planeAnchor] = planeNode
        node.addChildNode(planeNode)
    }
    
    func removePlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.messageBox.text = "Plane Removed"
        }
        if let planeNode = planes[planeAnchor] {
            planeNode.removeFromParentNode()
        }
    }
    
    func updatePlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        DispatchQueue.main.async {
//            self.messageBox.text = "Plane Updated"
//        }
        if let planeNode = planes[planeAnchor] {
            planeNode.updatePosition(planeAnchor)
        }
    }
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    
    //     Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
        case is ARObjectAnchor: processDetectedObject(node: node, anchor: anchor)
//        case is ARPlaneAnchor: displayPlane(node: node, anchor: anchor)
        default: return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
        case is ARObjectAnchor: updateObject(node: node, anchor: anchor)
//        case is ARPlaneAnchor: updatePlane(node: node, anchor: anchor)
        default: return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
        //        case is ARObjectAnchor: processDetectedObject(node: node, anchor: anchor)
        case is ARPlaneAnchor: removePlane(node: node, anchor: anchor)
        default: return
        }
    }
    
    func updateObject(node: SCNNode, anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        
        DispatchQueue.main.async {
            self.messageBox.text = """
            Object Updated:
            Name: \(objectAnchor.referenceObject.name!)
            Transform: \(objectAnchor.transform)
            """
            
            if let currentLegoScene = self.currentLegoScene {
                currentLegoScene.updateCurrentModel(objectAnchor)
                
                if let worldSessionConfig = self.sessionConfig as? ARWorldTrackingConfiguration {
                    self.configureDetectionObjects(sessionConfig: worldSessionConfig, groupName: "LegoModels_\(currentLegoScene.currentLayer)")
                }
            }
        }
    }
    
    func processDetectedObject(node: SCNNode, anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        
        DispatchQueue.main.async {
            self.messageBox.text = "Object Detected: \(objectAnchor.name!)"
            
            let objectNode = BoundingBox(objectAnchor)
//            node.addChildNode(objectNode)
            
            if let currentLegoScene = self.currentLegoScene {
                currentLegoScene.updateCurrentModel(objectAnchor)
            } else {
                self.currentLegoScene = LegoScene(objectAnchor)
            }
            
            if let modelNode = self.currentLegoScene?.currentModel {
                node.addChildNode(modelNode)
            }
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
