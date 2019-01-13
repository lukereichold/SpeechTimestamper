import UIKit
import SwiftGRPC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let stringPath = Bundle.main.path(forResource: "short", ofType: "flac") ?? ""

        let data = NSData(contentsOfFile: stringPath)! as Data
        SpeechService.sharedInstance.transcribeAudioData(data) { result in
            // stuff
        }
        
        return true
    }
    
}

