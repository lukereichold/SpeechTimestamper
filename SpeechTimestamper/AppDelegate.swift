import UIKit
import SwiftGRPC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let stringPath = Bundle.main.path(forResource: "short", ofType: "flac") ?? ""

//        let data = NSData(contentsOfFile: stringPath)! as Data
//        SpeechService.shared.transcribeAudioData(data) { result in
//            switch result {
//            case .success(let results):
//                print("success")
//            case .failure(let error):
//                print("bad")
//            }
//        }
        
        return true
    }
    
}

