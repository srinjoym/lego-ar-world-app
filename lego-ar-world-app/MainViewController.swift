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
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func configureDetectionObjects(_ layer: Int) {
        guard var referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: self.currentLegoScene!.currentModel.name, bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        referenceObjects = referenceObjects.filter {
            $0.name == "\(self.currentLegoScene!.currentModel.name)_\(layer-1)_Tracking" || $0.name == "\(self.currentLegoScene!.currentModel.name)_\(layer)_Detection"
        }
        
        if let worldSessionConfig = self.sessionConfig as? ARWorldTrackingConfiguration {
            worldSessionConfig.detectionObjects = referenceObjects
            session.run(worldSessionConfig, options: [])
        }
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

    @IBAction func addButton(_ button: UIButton) {
        let rowHeight = 45
        let popoverSize = CGSize(width: 250, height: rowHeight * Models.count)
        
        let objectViewController = ChooseModelViewController(size: popoverSize)
        objectViewController.delegate = self
        objectViewController.modalPresentationStyle = .popover
        objectViewController.popoverPresentationController?.delegate = self
        self.present(objectViewController, animated: true, completion: nil)
        
        objectViewController.popoverPresentationController?.sourceView = button
        objectViewController.popoverPresentationController?.sourceRect = button.bounds
    }
    
    @IBAction func hideButton(_ sender: Any) {
        if let currentNode = currentLegoScene?.currentNode {
                currentNode.isHidden = !currentNode.isHidden
        }
    }
    
    // MARK: - Planes
    
    var planes = [ARPlaneAnchor: PlaneNode]()
    
    func displayPlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = PlaneNode(planeAnchor)
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
        var previousLayer = 0
        if let currentLegoScene = self.currentLegoScene {
            previousLayer = currentLegoScene.currentLayer
            currentLegoScene.updatePlanes(planes)
            let didUpdateNode = currentLegoScene.updateCurrentNode(node: node, anchor: objectAnchor)
            
            if currentLegoScene.finished {
                self.messageBox.text = "You finished the model!"
            }
            else if didUpdateNode {
                self.messageBox.text = "Great Job! Let's move to layer \(previousLayer + 2)"
                
                // Update Detection Objects
                self.configureDetectionObjects(previousLayer + 2)
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

// MARK: - VirtualObjectSelectionViewControllerDelegate
extension MainViewController :ChooseModelViewControllerDelegate {
    func chooseModelViewController(_: ChooseModelViewController, object: LegoModel) {
        self.currentLegoScene = LegoScene(legoModel: object, planes: self.planes)
        configureDetectionObjects(2)
    }
}
