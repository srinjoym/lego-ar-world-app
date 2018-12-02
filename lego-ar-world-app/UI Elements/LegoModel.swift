//
//  Plane.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 11/29/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//
import SceneKit
import ARKit

class LegoModel: SCNNode {
    
    var objectAnchor: ARObjectAnchor
    var objectNode: SCNNode
    
    init(fileName: String, anchor: ARObjectAnchor, transform: SCNVector3? = nil) {
        self.objectAnchor = anchor
        
        let modelScene = SCNScene(named: fileName)
        
        guard let modelNode = modelScene?.rootNode else {
            fatalError("Could not load root node from model scene")
        }

        self.objectNode = modelNode.clone()
//        self.objectNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        super.init()
        
        self.addChildNode(objectNode)
        
        if let position = transform {
            self.position = position
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//    func updatePosition(_ anchor: ARObjectAnchor){
//        let referenceObject = anchor.referenceObject
//
//        self.objectGeometry = SCNBox(width: CGFloat(referenceObject.extent.x), height: CGFloat(referenceObject.extent.z), length: CGFloat(referenceObject.extent.y), chamferRadius: CGFloat(0))
//        self.position = SCNVector3(anchor.referenceObject.center.x, anchor.referenceObject.center.y, anchor.referenceObject.center.z)
//    }
}
