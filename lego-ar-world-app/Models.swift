//
//  Models.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 12/1/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//

import Foundation
import SceneKit

struct LegoModel {
    var name = String()
    var iconPath = String()
    var numLayers = Int()
}

let Models: [LegoModel] = [
    LegoModel(name: "LegoShip", iconPath: "ship", numLayers: 3),
    LegoModel(name: "Shanghai", iconPath: "shanghai", numLayers: 7),
    LegoModel(name: "London", iconPath: "london", numLayers: 5)
]

let ModelsDict: [String: LegoModel] = [
    "LegoShip": LegoModel(name: "LegoShip", iconPath: "ship", numLayers: 3),
    "Shanghai": LegoModel(name: "Shanghai", iconPath: "shanghai", numLayers: 7),
    "London": LegoModel(name: "London", iconPath: "london", numLayers: 5)
]
