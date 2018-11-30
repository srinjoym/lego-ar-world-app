import UIKit

enum Setting: String {
    // Bool settings with SettingsViewController switches
    case debugMode
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [:])
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
    
    @IBOutlet weak var debugModeSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSettings()
    }
    
    @IBAction func didChangeSetting(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
        case debugModeSwitch:
            defaults.set(sender.isOn, for: .debugMode)
        default: break
        }
    }
    
    private func populateSettings() {
        let defaults = UserDefaults.standard
        
        debugModeSwitch.isOn = defaults.bool(for: Setting.debugMode)
    }
}
