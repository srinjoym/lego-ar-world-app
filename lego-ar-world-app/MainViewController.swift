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
        configureSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func restartPlaneDetection() {
        // configure session
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
//            worldSessionConfig.planeDetection = .horizontal
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
        updateSettings()
    }
    
    var showFeaturePoints: Bool = UserDefaults.standard.bool(for: .showFeaturePoints) {
        didSet {
            configureSettings()
            UserDefaults.standard.set(showFeaturePoints, for: .showFeaturePoints)
        }
    }
    
    var showPlanes: Bool = UserDefaults.standard.bool(for: .showPlanes) {
        didSet {
            configureSettings()
            UserDefaults.standard.set(showPlanes, for: .showPlanes)
        }
    }
    
    var showOrigin: Bool = UserDefaults.standard.bool(for: .showWorldOrigin) {
        didSet {
            configureSettings()
            UserDefaults.standard.set(showOrigin, for: .showWorldOrigin)
        }
    }
    
    private func configureSettings() {
        if showFeaturePoints {
            sceneView.debugOptions.insert(.showFeaturePoints)
        } else {
            sceneView.debugOptions.remove(.showFeaturePoints)
        }
        
        if showPlanes {
            // Enable Plane Detection
            if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
                worldSessionConfig.planeDetection = .horizontal
                session.run(worldSessionConfig, options: [])
            }
        } else {
            if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
                worldSessionConfig.planeDetection = []
                session.run(worldSessionConfig, options: [])
            }
            
            for (_ , plane) in planes {
                plane.removeFromParentNode()
            }
            planes.removeAll()
        }
        
        if showOrigin {
            sceneView.debugOptions.insert(.showWorldOrigin)
        } else {
            sceneView.debugOptions.remove(.showWorldOrigin)
        }
    }
    
    private func updateSettings() {
        let defaults = UserDefaults.standard
        
        showFeaturePoints = defaults.bool(for: .showFeaturePoints)
        showPlanes = defaults.bool(for: .showPlanes)
        showOrigin = defaults.bool(for: .showWorldOrigin)
    }
    
    

    @IBAction func forwardButton(_ sender: Any) {
    }
    @IBAction func backButton(_ sender: Any) {
    }
    @IBAction func hideButton(_ sender: Any) {
        if let currentModel = currentLegoScene?.currentModel {
                currentModel.isHidden = !currentModel.isHidden
        }
    }
    
    // MARK: - Planes
    
    var planes = [ARPlaneAnchor: Plane]()
    
    func displayPlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = Plane(planeAnchor)
        planes[planeAnchor] = planeNode
        node.addChildNode(planeNode)
    }
    
    func removePlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let planeNode = planes[planeAnchor] {
            planeNode.removeFromParentNode()
        }
        planes.removeValue(forKey: planeAnchor)
    }
    
    func updatePlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let planeNode = planes[planeAnchor] {
            planeNode.updatePosition(planeAnchor)
        }
    }
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    
    //     Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            switch anchor {
            case is ARObjectAnchor: self.processDetectedObject(node: node, anchor: anchor)
            case is ARPlaneAnchor: self.displayPlane(node: node, anchor: anchor)
            default: return
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
//        case is ARObjectAnchor: updateObject(node: node, anchor: anchor)
        case is ARPlaneAnchor: updatePlane(node: node, anchor: anchor)
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
    
//    func updateObject(node: SCNNode, anchor: ARAnchor) {
//        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
//        
//        DispatchQueue.main.async {
//            self.messageBox.text = """
//            Object Updated:
//            Name: \(objectAnchor.referenceObject.name!)
//            Transform: \(objectAnchor.transform)
//            """
//            
//            if let currentLegoScene = self.currentLegoScene {
//                currentLegoScene.updateCurrentModel(objectAnchor.name!)
//                
//                if let worldSessionConfig = self.sessionConfig as? ARWorldTrackingConfiguration {
//                    self.configureDetectionObjects(sessionConfig: worldSessionConfig, groupName: "LegoModels_\(currentLegoScene.currentLayer+1)")
//                }
//            }
//        }
//    }
    
    func processDetectedObject(node: SCNNode, anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        
//        if (self.showFeaturePoints) {
//            self.messageBox.text += "\n Object Detected: \(objectAnchor.name!)"
//        }
        
        
        var previousLayer = 0
        if let currentLegoScene = self.currentLegoScene {
            previousLayer = currentLegoScene.currentLayer
            currentLegoScene.updatePlanes(planes)
            currentLegoScene.updateCurrentModel(objectAnchor.name!)
        } else {
            self.currentLegoScene = LegoScene(anchorName: objectAnchor.name!, planes: planes)
        }
        
        if let modelNode = self.currentLegoScene?.currentModel {
            node.addChildNode(modelNode)
            
            if (currentLegoScene!.currentLayer > previousLayer) {
                self.messageBox.text = "Great Job! Let's move to layer \((currentLegoScene?.currentLayer)! + 1)"
            }
        }
        
        if let currentLegoScene = self.currentLegoScene {
            if currentLegoScene.finished {
                self.messageBox.text = "You finished the model!"
            }
            
            if let worldSessionConfig = self.sessionConfig as? ARWorldTrackingConfiguration {
                if (currentLegoScene.currentLayer != currentLegoScene.totalLayers) {
                    self.configureDetectionObjects(sessionConfig: worldSessionConfig, groupName: "LegoModels_\(currentLegoScene.currentLayer+1)")
                    session.run(worldSessionConfig, options: [])
                }
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
