import UIKit
import AVFoundation

final class RecordingViewController: UIViewController {
    @IBOutlet private weak var transcriptTextView: UITextView!
    @IBOutlet private weak var recordButton: RecordButton!
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var audioFileName: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognizers()
        requestRecordingAccess()
    }
    
    private func setupRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        recordButton.observer = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Recording Logic

extension RecordingViewController {
    private func requestRecordingAccess() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [weak self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self?.recordButton.isEnabled = false
                        print("Failed to grant microphone recording permission!")
                    }
                }
            }
        } catch {
            print("Failed to configure audio recording session!")
        }
    }

    private func startRecording() {
        let filename = String(Int.random(in: 0 ..< 1000000))
        audioFileName = FileManager.default.documentsDirectory().appendingPathComponent("\(filename).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
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

    private func finishRecording(success: Bool) {
        print("Recording finished with success: \(success)")
        audioRecorder.stop()
        audioRecorder = nil
    }
}

extension RecordingViewController: RecordButtonObserver {
    func recordTapped() {
        startRecording()
    }
    
    func stopTapped() {
        finishRecording(success: true)
    }
}

extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
