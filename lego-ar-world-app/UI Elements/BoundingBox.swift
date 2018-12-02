//
//  Plane.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 11/29/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//
import SceneKit
import ARKit

class BoundingBox: SCNNode {
    
    var objectAnchor: ARObjectAnchor
    var objectGeometry: SCNBox
    var objectNode: SCNNode
    
    init(_ anchor: ARObjectAnchor) {
    
        self.objectAnchor = anchor
        let referenceObject = anchor.referenceObject
        
        self.objectGeometry = SCNBox(width: CGFloat(referenceObject.extent.x), height: CGFloat(referenceObject.extent.z), length: CGFloat(referenceObject.extent.y), chamferRadius: CGFloat(0))
        
        let material = SCNMaterial()
        self.objectGeometry.materials = [material]
        
        self.objectGeometry.firstMaterial?.transparency = 0.2

        self.objectNode = SCNNode(geometry: objectGeometry)
        self.objectNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        super.init()
        
        self.addChildNode(objectNode)
        
        self.position = SCNVector3(anchor.referenceObject.center.x, anchor.referenceObject.center.y, anchor.referenceObject.center.z)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(_ anchor: ARObjectAnchor){
        let referenceObject = anchor.referenceObject
        
        self.objectGeometry = SCNBox(width: CGFloat(referenceObject.extent.x), height: CGFloat(referenceObject.extent.z), length: CGFloat(referenceObject.extent.y), chamferRadius: CGFloat(0))
        self.position = SCNVector3(anchor.referenceObject.center.x, anchor.referenceObject.center.y, anchor.referenceObject.center.z)
    }
}
