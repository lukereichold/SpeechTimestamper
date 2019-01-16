import UIKit

final class AlignmentResultsViewController: UIViewController {
    
    var audioFileName: URL!
    var recognitionResults: [RecognitionResult]? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
