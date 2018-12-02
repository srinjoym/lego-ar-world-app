//
//  ARSceneViewExtension.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 11/29/18.
//  Copyright © 2018 Srinjoy Majumdar. All rights reserved.
//
import ARKit
import Foundation
import SceneKit

extension ARSCNView {
    func setUp(viewController: MainViewController, session: ARSession) {
        delegate = viewController
        self.session = session
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
        if let camera = pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.automaticallyAdjustsZRange = true
        }
        
        debugOptions = ARSCNDebugOptions.showFeaturePoints
    }
}
