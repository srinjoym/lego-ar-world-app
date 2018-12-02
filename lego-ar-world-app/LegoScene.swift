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
    
    var modelName = String("")
    var totalLayers = Int()
    var currentLayer = Int()
    var currentModel:LegoModel?
    
    enum LegoSceneError: Error {
        case modelChanged
        case corruptResourceName
    }
    
    struct ResourceName {
        var modelName = String("")
        var layerNum = Int()
    }
    
    init(_ anchor: ARObjectAnchor) {
        if let anchorName = anchor.name {
            let resourceName = self.parseResourceName(anchorName)
            self.modelName = resourceName.modelName
            self.currentLayer = resourceName.layerNum
            self.setTotalLayers()
            self.updateCurrentModel(anchor)
        }
    }
    
    func updateCurrentModel(_ anchor: ARObjectAnchor) {
        guard let anchorName = anchor.name else { return }
        
        let resourceName = self.parseResourceName(anchorName)
        
        if (resourceName.layerNum >= self.currentLayer && resourceName.layerNum < self.totalLayers){
            // User hasn't finished model yet
            self.modelName = resourceName.modelName
//            if (resourceName.layerNum != self.currentLayer) {
                self.currentLayer = resourceName.layerNum
                let nextFilePath = "art.scnassets/" + self.nextLayerModelName()
                
                //            if let currentModel = self.currentModel {
                //                currentModel.removeFromParentNode()
                //            }
                if let layers = StoredLegoModels[self.modelName] {
                    let transform = layers[self.currentLayer-1].transform
                    self.currentModel = LegoModel(fileName: nextFilePath, anchor: anchor, transform: transform)
                } else {
                    self.currentModel = LegoModel(fileName: nextFilePath, anchor: anchor)
                }
//            }
        } else {
            // User has finished model!!
        }
    }
    
    func parseResourceName(_ name: String) -> ResourceName {
        let contents = name.components(separatedBy: "_")
        
        if let layerNum = Int(contents[1]) {
            return ResourceName(modelName: contents[0], layerNum: layerNum)
        } else {
            return ResourceName(modelName: "", layerNum: Int())
        }
    }
    
    func nextLayerModelName() -> String {
        return self.modelName + "_" + String(self.currentLayer+1) + ".dae"
    }
    
    func setTotalLayers() {
        if let layers = StoredLegoModels[self.modelName] {
            self.totalLayers = layers.count
        }
    }
}
