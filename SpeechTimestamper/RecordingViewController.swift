import UIKit
import NVActivityIndicatorView

final class RecordingViewController: UIViewController {
    @IBOutlet private weak var transcriptTextView: UITextView!
    @IBOutlet private weak var recordButton: RecordButton!
    @IBOutlet private weak var generateButton: UIButton!
    @IBOutlet private weak var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognizers()
        AudioController.shared.delegate = self
        AudioController.shared.requestRecordingPermission { [weak self] (givenAccess) in
            self?.recordButton.isEnabled = givenAccess
        }
    }
    
    private func setupRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        recordButton.observer = self
        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func generateTapped() {
        showLoadingSpinner(true)
        let data = try! Data(contentsOf: AudioController.shared.audioFileName)
        SpeechService.shared.transcribeAudioData(data) { [weak self] (response) -> (Void) in
            switch response {
            case .success(let results):
                DispatchQueue.main.async {
                    self?.presentResults(results)
                }
            case .failure(let error):
                print("Speech Service error: \(error)")
            }
            DispatchQueue.main.async {
                self?.showLoadingSpinner(false)
            }
        }
    }
    
    private func presentResults(_ results: [RecognitionResult]) {
        let resultsVC = storyboard?.instantiateViewController(withIdentifier: "AlignmentResultsViewController") as! AlignmentResultsViewController
        resultsVC.recognitionResults = results
        resultsVC.providedTranscript = transcriptTextView.text
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    private func showLoadingSpinner(_ show: Bool) {
        view.isUserInteractionEnabled = !show
        transcriptTextView.alpha = show ? 0.2 : 1.0
        recordButton.alpha = show ? 0.2 : 1.0
        generateButton.alpha = show ? 0.2 : 1.0
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension RecordingViewController: RecordButtonObserver {
    func recordTapped() {
        AudioController.shared.startRecording()
    }
    
    func stopTapped() {
        AudioController.shared.finishRecording(success: true)
    }
}

extension RecordingViewController: AudioControllerDelegate {
    func didFinishRecording(withSuccess success: Bool) {
        generateButton.isEnabled = success
    }
}
