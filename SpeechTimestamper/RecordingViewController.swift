import UIKit
import AVFoundation

let SAMPLE_RATE = 16000

final class RecordingViewController: UIViewController {
    @IBOutlet private weak var transcriptTextView: UITextView!
    @IBOutlet private weak var startStopRecordButton: UIButton!
    
    var audioData: NSMutableData!
    
    private var isRecording = false {
        didSet {
            if isRecording {
                startRecording()
            } else {
                stopRecording()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Record"
        setupRecognizers()
//        AudioController.sharedInstance.delegate = self
    }
    
    private func setupRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        startStopRecordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func recordButtonTapped() {
        isRecording.toggle()
    }
    
    private func startRecording() {
        startStopRecordButton.setTitle("Stop Recording", for: .normal)
    }
    
    private func stopRecording() {
        startStopRecordButton.setTitle("Start Recording", for: .normal)
    }

//    @IBAction func recordAudio(_ sender: NSObject) {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSession.Category.record)
//        } catch {
//
//        }
//        audioData = NSMutableData()
//        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
//
//        SpeechService.shared.sampleRate = SAMPLE_RATE
//        _ = AudioController.sharedInstance.start()
//    }
//
//    @IBAction func stopAudio(_ sender: NSObject) {
//        _ = AudioController.sharedInstance.stop()
//        SpeechRecognitionService.sharedInstance.stopStreaming()
//    }
//
//    func processSampleData(_ data: Data) -> Void {
//        audioData.append(data)
//
//        // We recommend sending samples in 100ms chunks
//        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
//            * Double(SAMPLE_RATE) /* samples/second */
//            * 2 /* bytes/sample */);
//
//        if (audioData.length > chunkSize) {
//            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
//                                                                    completion:
//                { [weak self] (response, error) in
//                    guard let strongSelf = self else {
//                        return
//                    }
//
//                    if let error = error {
//                        strongSelf.textView.text = error.localizedDescription
//                    } else if let response = response {
//                        var finished = false
//                        print(response)
//                        for result in response.resultsArray! {
//                            if let result = result as? StreamingRecognitionResult {
//                                if result.isFinal {
//                                    finished = true
//                                }
//                            }
//                        }
//                        strongSelf.textView.text = response.description
//                        if finished {
//                            strongSelf.stopAudio(strongSelf)
//                        }
//                    }
//            })
//            self.audioData = NSMutableData()
//        }
//    }
}
