import Foundation

@objc(OsxUtils)
class OsxUtils : CDVPlugin {
    
    struct ERROR {
        static let ARGUMENT_INVALID = 1
        static let UNKNOWN = 9999
    }
    
    func exitApp(_ command: CDVInvokedUrlCommand) {
        NSApp.terminate(self)
    }
    
    func openUrl(_ command: CDVInvokedUrlCommand) {
        guard let url = URL(string: command.argument(at: 0) as! String) else {
            _sendErrorResult(command, code: ERROR.ARGUMENT_INVALID, message: "url: invalid")
            return
        }
        
        if NSWorkspace.shared().open(url) {
            _sendOkResult(command)
        } else {
            _sendErrorResult(command, code: ERROR.UNKNOWN, message: "cannot open")
        }
    }
    
    func resize(_ command: CDVInvokedUrlCommand) {
        let window = self.webView.window!
        let fullscreen = command.argument(at: 0, withDefault: true) as! Bool
        
        if fullscreen {
            CDVWindowSizeCommand.makeFullScreen(window)
            window.styleMask = NSFullScreenWindowMask
            _sendOkResult(command)
            return
        }
        
        guard let json2 = (try? JSONSerialization.jsonObject(with: ((command.argument(at: 1) as? String)?.data(using: .utf8))!, options: [])) as? [String: Float] else {
            _sendErrorResult(command, code: ERROR.ARGUMENT_INVALID, message: "rect: Argument Invalid")
            return
        }
        let rect = (
            x: json2["x"],
            y: json2["y"],
            width: json2["width"],
            height: json2["height"]
        )
        
        let json3 = (try? JSONSerialization.jsonObject(with: ((command.argument(at: 2, withDefault: "{}") as? String)?.data(using: .utf8))!, options: [])) as? [String: Bool]
        
        let flags = (
            minimize: json3?["minimize"] == nil ? true : json3!["minimize"]!,
            maximize: json3?["maximize"] == nil ? true : json3!["maximize"]!,
            resize: json3?["resize"] == nil ? true : json3!["resize"]!,
            close: json3?["close"] == nil ? true : json3!["close"]!,
            border: json3?["border"] == nil ? true : json3!["border"]!
        )
        
        CDVWindowSizeCommand.removeFullScreen(window)
        
        let windowRect = window.frame
        let frame = NSRect(
            x: CGFloat(rect.x ?? Float(windowRect.origin.x)),
            y: CGFloat(rect.y ?? Float(windowRect.origin.y)),
            width: CGFloat(rect.width ?? Float(windowRect.width)),
            height: CGFloat(rect.height ?? Float(windowRect.height))
        )

        var mask = NSWindowStyleMask()
        if flags.border {
            mask.insert(.titled)
            if flags.minimize { mask.insert(.miniaturizable) }
            if flags.close { mask.insert(.closable) }
            if flags.resize { mask.insert(.resizable) }
        } else {
            mask.insert(.borderless)
        }
        
        window.setFrame(frame, display: true)
        window.styleMask = mask
        
        if flags.border {
            if let button = window.standardWindowButton(.zoomButton) {
                button.isHidden = !flags.maximize
                button.isEnabled = !flags.maximize
            }
        }
 
        _sendOkResult(command)
    }
    
    private func _sendOkResult(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.send(_getOkResult(), callbackId: command.callbackId)
    }
    
    private func _sendErrorResult(_ command: CDVInvokedUrlCommand, code: Int, message: String) {
        self.commandDelegate.send(_getErrorResult(code, message), callbackId: command.callbackId)
    }
    
    private func _getErrorResult(_ code: Int, _ message: String) -> CDVPluginResult {
        var obj = [[String:Any]]()
        obj.append(["code": code, "message": message])
        return CDVPluginResult(status:CDVCommandStatus_ERROR, messageAs: obj)
    }
    
    private func _getOkResult() -> CDVPluginResult {
        return CDVPluginResult(status: CDVCommandStatus_OK)
    }
}
