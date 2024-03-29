import Orion
import UIKit
import RAMUnderTimeC

// MARK: - Helper functions

/// Returns true if the device is a Face-ID iPhone.
fileprivate func isFaceIDiPhone() -> Bool {
    return !UIDevice.currentIsIPad() && !UIDevice._hasHomeButton()
}

/// Returns true if the passed in label is the time label.
fileprivate func isTimeLabel(_ label: _UIStatusBarStringView) -> Bool {
    // TODO: - The implementation is very dependent on this variable which may change in future iOS versions.
    // Would be best to find an alternative solution to identify which of the labels is the time label.
    return label.fontStyle == 1
}

/// Returns the appropriate separator string dependent on whether the device is a Face-ID iPhone or not.
fileprivate func separatorText() -> String {
    return isFaceIDiPhone() ? "\n" : " - "
}

// MARK: - Status bar

class _UIStatusBarStringView_Hook: ClassHook<_UIStatusBarStringView> {
    func initWithFrame(_ frame: CGRect) -> Target {
        // Add a notification observer that listens for text update requests.
        NotificationCenter.default.addObserver(
            target,
            selector: #selector(RUT_updateText),
            name: Notification.Name("RUT_updateText"),
            object: nil
        )
        return orig.initWithFrame(frame)
    }

    func applyStyleAttributes(_ arg1: AnyObject) {
        orig.applyStyleAttributes(arg1)
        // Adjust the font size, alignment, etc if the label is the time label.
        guard isTimeLabel(target) else { return }
        target.numberOfLines = 2
        target.textAlignment = .center
        target.font = .systemFont(ofSize: 12)
    }

    func setText(_ text: String) {
        // Check if this label is the time label, then add the ram to the label.
        guard isTimeLabel(target) else {
            orig.setText(text)
            return
        }
        
        var txt: String {
            if text.contains(separatorText()) {
                return text.components(separatedBy: separatorText()).first!
            }
            return text
        }
        
        orig.setText("\(txt)\(separatorText())\(GSMemory.get_free_mem()) MB")
    }

    //orion: new
    func RUT_updateText() {
        // Updates the time label's text when the update text notification is recieved.
        setText(target.text!)
    }
}

// MARK: - SpringBoard

// QOL / Fix updating text when status bar style changes, or when front-most app changes.
class SpringBoard_Hook: ClassHook<SpringBoard> {
    func frontDisplayDidChange(_ arg1: AnyObject?) {
        orig.frontDisplayDidChange(arg1)
        // Post a notification to update the time label's text upon app change.
        NotificationCenter.default.post(
            name: NSNotification.Name("RUT_updateText"),
            object: nil
        )
    }
}

class SBIconController_Hook: ClassHook<SBIconController> {
    func _controlCenterWillDismiss(_ arg1: AnyObject) {
        orig._controlCenterWillDismiss(arg1)
        // Post a notification to update the time label's text upon closing the control centre.
        NotificationCenter.default.post(
            name: NSNotification.Name("RUT_updateText"),
            object: nil
        )
    }
}
