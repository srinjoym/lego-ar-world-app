import Foundation
import ARKit

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "Tracking is currently unavailable."
        case .normal:
            return "Tracking state is normal."
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Tracking limited\nToo much camera movement"
            case .insufficientFeatures:
                return "Tracking Limited\nNot enough surface detail"
            case .initializing:
                return "Tracking initializing"
            case .relocalizing:
                return "Tracking relocalizing"
            }
        }
    }
}
