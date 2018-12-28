import UIKit

enum Setting: String {
    // Bool settings with SettingsViewController switches
    case showFeaturePoints
    case showPlanes
    case showWorldOrigin
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.showFeaturePoints.rawValue: false,
            Setting.showPlanes.rawValue: false,
            Setting.showWorldOrigin.rawValue: false
            ])
    }
}
extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    func integer(for setting: Setting) -> Int {
        return integer(forKey: setting.rawValue)
    }
    func set(_ integer: Int, for setting: Setting) {
        set(integer, forKey: setting.rawValue)
    }
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var showFeaturePointsSwitch: UISwitch!
    @IBOutlet weak var showPlanesSwitch: UISwitch!
    @IBOutlet weak var showOriginSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSettings()
    }
    
    @IBAction func didChangeSetting(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
        case showFeaturePointsSwitch:
            defaults.set(sender.isOn, for: .showFeaturePoints)
        case showPlanesSwitch:
            defaults.set(sender.isOn, for: .showPlanes)
        case showOriginSwitch:
            defaults.set(sender.isOn, for: .showWorldOrigin)
        default: break
        }
    }
    
    private func populateSettings() {
        let defaults = UserDefaults.standard
        
        showFeaturePointsSwitch.isOn = defaults.bool(for: Setting.showFeaturePoints)
        showPlanesSwitch.isOn = defaults.bool(for: Setting.showPlanes)
        showOriginSwitch.isOn = defaults.bool(for: Setting.showWorldOrigin)
    }
}
