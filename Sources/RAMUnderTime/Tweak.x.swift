import Orion
import UIKit
import RAMUnderTimeC

class _UIStatusBarStringView_Hook: ClassHook<_UIStatusBarStringView> {

    func initWithFrame(_ frame: CGRect) -> Target {
        NotificationCenter.default.addObserver(target, selector: #selector(RUT_update_text), name: Notification.Name("RUT_UpdateText"), object: nil)
        return orig.initWithFrame(frame)
    }
    
    func applyStyleAttributes(_ arg1: AnyObject) {
        orig.applyStyleAttributes(arg1)
                
        guard RUT_Label_Is_Suitable() else {
            return
        }
       
        target.numberOfLines = 2
        target.textAlignment = NSTextAlignment.center
        target.font = UIFont.systemFont(ofSize: 12)
    }
    
    func setText(_ text: String) {
        if RUT_Label_Is_Suitable() {
            let txt = text.contains(RUT_separator_text()) ? text.components(separatedBy: RUT_separator_text())[0] : text
            orig.setText("\(txt)\(RUT_separator_text())\(GSMemory().get_free_mem()) MB")
        } else {
            orig.setText(text)
        }
    }

    //orion: new
    func RUT_update_text() {
        setText(target.text!)
    }
    
    //orion: new
    func RUT_Label_Is_Suitable() -> Bool {
        return target.fontStyle == 1
    }
    
    //orion: new
    func RUT_is_FaceID_iPhone() -> Bool {
        return (!UIDevice.currentIsIPad() && UIDevice.tf_deviceHasFaceID())
    }
    
    //orion: new
    func RUT_separator_text() -> String {
        return RUT_is_FaceID_iPhone() ? "\n" : " - "
    }
}

//MARK: - Fix updating text when status bar style changes, or when front-most app changes.
class SpringBoard_Hook: ClassHook<SpringBoard> {
    func frontDisplayDidChange(_ arg1: AnyObject) {
        orig.frontDisplayDidChange(arg1)
        NotificationCenter.default.post(name: NSNotification.Name("RUT_UpdateText"), object: nil)
    }
}

class SBIconController_Hook: ClassHook<SBIconController> {
    func _controlCenterWillDismiss(_ arg1: AnyObject) {
        orig._controlCenterWillDismiss(arg1)
        NotificationCenter.default.post(name: NSNotification.Name("RUT_UpdateText"), object: nil)
    }
}
