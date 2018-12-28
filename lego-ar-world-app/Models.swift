//
//  Models.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 12/1/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//

import Foundation
import SceneKit

struct LayerInfo {
    var layer = Int()
    var transform = SCNVector3()
}

let StoredLegoModels: [String: [LayerInfo]] = [
    "LegoShip": [
        LayerInfo(layer: 1, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 2, transform: SCNVector3(-0.048, 0, -0.016)),
        LayerInfo(layer: 3, transform: SCNVector3(0,0,0))
    ],
    "Shanghai": [
        LayerInfo(layer: 1, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 2, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 3, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 4, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 5, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 6, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 7, transform: SCNVector3(0,0,0))
    ],
    "London": [
        LayerInfo(layer: 1, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 2, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 3, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 4, transform: SCNVector3(0,0,0)),
        LayerInfo(layer: 5, transform: SCNVector3(0,0,0))
    ]
]
