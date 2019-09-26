import UIKit
import AVKit

struct Word {
    let word: String
    let startTime: Int32
    let startTimeFloat: Double
}

final class AlignmentResultsViewController: UIViewController {
    
    @IBOutlet private weak var resultsTextView: UITextView!
    @IBOutlet private weak var alignedTextView: UITextView!
    @IBOutlet private weak var playButton: UIButton!
    
    private var transcribedWords: [Word]?
    var providedTranscript: String?
    
    /// # Run Loop
    private var audioPlayer: AVAudioPlayer!
    private var timer = Timer()
    
    var recognitionResults: [RecognitionResult] = [] {
        didSet {
            loadViewIfNeeded()
            let words = recognitionResults.first?.alternatives.first?.words
            transcribedWords = words?.map { word in
                let adjustedStartTime = Int32(word.startTime.seconds) * Int32(1E3) + word.startTime.nanos / Int32(1E6)
                
                return Word(word: word.word, startTime: adjustedStartTime, startTimeFloat: Double(adjustedStartTime) / 1000.0)
            }
            setTranscriptionText()
            performAlignment()
        }
    }
}

extension AlignmentResultsViewController {

    private func setTranscriptionText() {
        resultsTextView.text = transcribedWords?.compactMap { wordInfo in
            return "\(wordInfo.word): \(wordInfo.startTimeFloat)s"
            }.joined(separator: ", ")
    }
    
    /// TODO
    private func performAlignment() {
        
        resetAlignedTextView()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @objc private func timerLoop() {
        updateAlignedText(for: audioPlayer.currentTime)
    }
    
    private func updateAlignedText(for currentTime: TimeInterval) {
        
        guard let idx = transcribedWords?.lastIndex(where: { currentTime >= $0.startTimeFloat }) else {
            return
        }
        
        let fullText = transcribedWords?.map { $0.word }.joined() ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont(name: "PingFangSC-Regular", size: 30)!, range: NSMakeRange(0, transcribedWords!.count))
        attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: NSMakeRange(idx, 1))
        
        alignedTextView.attributedText = attributedString
    }
    
    func resetAlignedTextView() {
        let fullText = transcribedWords?.map { $0.word }.joined() ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont(name: "PingFangSC-Regular", size: 30)!, range: NSMakeRange(0, transcribedWords!.count))
        alignedTextView.attributedText = attributedString
    }
    
    @IBAction private func playButtonTapped(_ sender: Any) {
        playButton.isEnabled = false
        prepareForAudioPlayback()
        audioPlayer.play()
        startTimer()
    }
    
    // MARK: - Playing back recorded audio
    
    private func prepareForAudioPlayback() {
        guard let audioFile = AudioController.shared.audioFileName else { return }
        guard FileManager.default.fileExists(atPath: audioFile.path) else {
            print("This file should exist!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch {
            print("Unable to initialize AVAudioPlayer with contents of \(String(describing: audioFile))")
        }
    }
}

extension AlignmentResultsViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isEnabled = true
        timer.invalidate()
        resetAlignedTextView()
    }
}
