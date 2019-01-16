import Foundation
import AVFoundation

protocol AudioControllerDelegate: class {
    func didFinishRecording(withSuccess success: Bool)
}

final class AudioController: NSObject {
    weak var delegate: AudioControllerDelegate?
    static let shared = AudioController()
    let sampleRate = 12000
    var audioFileName: URL!
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    
    private override init() {}
    
    // MARK: - Public
    
    func requestRecordingPermission(completion: @escaping (Bool) -> Void) {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        completion(allowed)
                        print("Failed to grant microphone recording permission!")
                    }
                }
            }
        } catch {
            print("Failed to configure audio recording session!")
        }
    }
    
    func startRecording() {
        let filename = String(Int.random(in: 0 ..< 1000000))
        audioFileName = FileManager.default.documentsDirectory().appendingPathComponent("\(filename).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error starting recording session")
        }
    }
    
    func finishRecording(success: Bool) {
        print("Recording finished with success: \(success)")
        audioRecorder.stop()
        audioRecorder = nil
        delegate?.didFinishRecording(withSuccess: success)
    }
    
}

extension AudioController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
