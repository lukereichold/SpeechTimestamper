import UIKit

final class AlignmentResultsViewController: UIViewController {
    
    @IBOutlet private weak var resultsTextView: UITextView!
    
    private let audioFileName = AudioController.shared.audioFileName
    
    var providedTranscript: String?
    var recognitionResults: [RecognitionResult] = [] {
        didSet {
            loadViewIfNeeded()
            resultsTextView.text = recognitionResults.first?.alternatives.first?.transcript
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
