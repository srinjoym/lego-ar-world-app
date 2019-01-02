//
//  LegoScene.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 11/29/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//
import SceneKit
import ARKit

class LegoScene {
    var viewController: MainViewController
    var currentModel: LegoModel
    var currentNode: LegoNode?
    var currentLayer: Int
    var planes = [ARPlaneAnchor: PlaneNode]()
    
    var finished = false
    
    enum AnchorType: String {
        case Tracking = "Tracking"
        case Detection = "Detection"
    }
    
    init(viewController: MainViewController, legoModel: LegoModel, planes: [ARPlaneAnchor: PlaneNode]) {
        self.viewController = viewController
        self.currentModel = legoModel
        self.planes = planes
        self.currentLayer = 0
        self.viewController.configureDetectionObjects(modelName: legoModel.name, layer: 1)
        self.viewController.messageManager.queueMessage("Initialized \(legoModel.name)")
    }
    
    func updateCurrentNode(node: SCNNode, anchor: ARObjectAnchor) {
        let name = anchor.name!
        let contents = name.components(separatedBy: "_")
        
        if (contents.count >= 3) {
            let layerIndex = Int(contents[1])!
            
            if let objectType = AnchorType(rawValue: contents[2]) {
                switch objectType {
                case .Tracking: attachNodeToAnchor(layerIndex: layerIndex, node: node)
                case .Detection: processDetectedNode(layerIndex)
                }
            }
        }
    }
    
    func updatePlanes(_ planes: [ARPlaneAnchor: PlaneNode]) {
        self.planes = planes
    }
    
    func attachNodeToAnchor(layerIndex: Int, node: SCNNode) {
        if let currentNode = self.currentNode {
            if currentNode.parent == nil && layerIndex == self.currentLayer - 1 {
                // attach node to this anchor
                node.addChildNode(currentNode)
                viewController.messageManager.queueMessage("London_\(layerIndex)_Tracking found")
            }
        }
    }
    
    func processDetectedNode(_ layerIndex: Int) {
        if layerIndex >= currentModel.numLayers {
            finished = true
            viewController.messageManager.queueMessage("Congratulations! You finished the model.")
        }
        else if layerIndex >= currentLayer {
            let nextFilePath = "art.scnassets/" + getLayerModelName(layerIndex+1)
            
            currentNode = LegoNode(fileName: nextFilePath)
            currentLayer = layerIndex + 1
            viewController.messageManager.queueMessage("London_\(layerIndex)_Detection found")
            viewController.configureDetectionObjects(modelName: currentModel.name, layer: currentLayer)
        }

    }
    
    func getLayerModelName(_ layerIndex: Int) -> String {
        return currentModel.name + "_" + String(layerIndex) + ".dae"
    }
}
