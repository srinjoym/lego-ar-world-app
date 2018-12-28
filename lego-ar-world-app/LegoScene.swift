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
    
    var currentModel: LegoModel
    var currentNode: LegoNode?
    var currentLayer: Int
    var planes = [ARPlaneAnchor: PlaneNode]()
    
    var finished = false
    
    enum LegoSceneError: Error {
        case modelChanged
        case corruptResourceName
    }
    
    init(_ legoModel: LegoModel) {
        self.currentModel = legoModel
        self.currentLayer = 1
    }
    
    init(legoModel: LegoModel, planes: [ARPlaneAnchor: PlaneNode]) {
        self.currentModel = legoModel
        self.planes = planes
        self.currentLayer = 1
    }
    
    func updateCurrentNode(node: SCNNode, anchor: ARObjectAnchor) -> Bool {
        let anchorName = anchor.name!
        let previousLayer = self.currentLayer
        self.parseResourceName(anchorName)
        
        if let currentNode = self.currentNode {
            if self.currentLayer > previousLayer {
                node.addChildNode(currentNode)
                return true
            }
        }
        return false
    }
    
    func updatePlanes(_ planes: [ARPlaneAnchor: PlaneNode]) {
        self.planes = planes
    }
    
    func parseResourceName(_ name: String) {
        let contents = name.components(separatedBy: "_")
        
        if (contents.count >= 3) {
            let layerNum = Int(contents[1])!
            let objectType = contents[2]
            
            if (objectType != "Tracking") {
                if layerNum >= self.currentModel.numLayers {
                    self.finished = true
                }
                else if layerNum >= self.currentLayer {
                    let nextFilePath = "art.scnassets/" + self.nextLayerModelName()
                    
                    self.currentNode = LegoNode(fileName: nextFilePath)
                    self.currentLayer = layerNum
                }
            }
        }
    }
    
    func nextLayerModelName() -> String {
        return self.currentModel.name + "_" + String(self.currentLayer+1) + ".dae"
    }
}
