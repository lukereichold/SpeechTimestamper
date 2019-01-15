import Foundation

protocol AudioControllerDelegate: class { }

// TODO: Remove this class
final class AudioController {
    weak var delegate: AudioControllerDelegate?
    static let shared = AudioController()
    
    private init() {}

    
}
