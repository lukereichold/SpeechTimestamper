import Foundation

struct Keys {
    static func readGcpKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else { return "" }
        let plist = NSDictionary(contentsOfFile: filePath)
        return plist?.object(forKey: "GOOGLE_API_KEY") as! String
    }
}
