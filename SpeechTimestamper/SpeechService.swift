import Foundation
import SwiftGRPC

enum SpeechRecognitionResult {
    case success([Google_Cloud_Speech_V1p1beta1_SpeechRecognitionResult])
    case failure(Error)
}

final class SpeechService {
    private var speechClient: Google_Cloud_Speech_V1p1beta1_SpeechServiceClient!
    private var operationsClient: Google_Longrunning_OperationsServiceClient!
    var sampleRate: Int = 12000
    
    static let sharedInstance = SpeechService()
    
    func transcribeAudioData(_ audioData: Data,
                             completion: @escaping (SpeechRecognitionResult) -> (Void)) {
        
        speechClient = Google_Cloud_Speech_V1p1beta1_SpeechServiceClient(address: "speech.googleapis.com")
        speechClient.metadata = try! Metadata(["x-goog-api-key": Keys.readGcpKey()])
        
        operationsClient = Google_Longrunning_OperationsServiceClient(address: "speech.googleapis.com")
        operationsClient.metadata = try! Metadata(["x-goog-api-key": Keys.readGcpKey()])
        
        var recognitionConfig = Google_Cloud_Speech_V1p1beta1_RecognitionConfig()
        recognitionConfig.encoding = .flac // linear16 otherwise
        recognitionConfig.sampleRateHertz = Int32(sampleRate)
        recognitionConfig.languageCode = "zh-cmn"
        recognitionConfig.maxAlternatives = 30
        recognitionConfig.enableWordTimeOffsets = true
        
        var audio = Google_Cloud_Speech_V1p1beta1_RecognitionAudio()
        audio.content = audioData
        
        var longRunningRequest = Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeRequest()
        longRunningRequest.config = recognitionConfig
        longRunningRequest.audio = audio

        do {
            _ = try speechClient.longRunningRecognize(longRunningRequest) { (longRunningOperation, callResult) in
                
                guard callResult.success else {
                    completion(.failure(NSError(domain: callResult.description, code: callResult.statusCode.rawValue, userInfo: nil)))
                    return
                }
                
                DispatchQueue.global().async {
                    var operation: Google_Longrunning_Operation = longRunningOperation!
                    repeat {
                        if let op = self.pollOperation(withName: operation.name) {
                            operation = op
                        }
                    } while !operation.done
                    
                    debugPrint("error: \(operation.error)")
                    if let metadata = self.unpackMetadata(forOperation: operation) {
                        debugPrint("==== Metadata ====", metadata)
                    }
                    
                    // Because `done` == `true`, exactly one of `error` or `response` is set.
                    if let results = self.unpackResponse(forOperation: operation)?.results {
                        completion(.success(results))
                    } else {
                        completion(.failure(NSError(domain: operation.error.message, code: Int(operation.error.code), userInfo: nil)))
                    }
                }
            }
        } catch let error as NSError {
            completion(.failure(error))
        }
    }
}

extension SpeechService {
    
    private func unpackMetadata(forOperation operation: Google_Longrunning_Operation) -> Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeMetadata? {
        guard operation.metadata.isA(Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeMetadata.self) else { return nil }
        return try? Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeMetadata(unpackingAny: operation.metadata)
    }
    
    private func unpackResponse(forOperation operation: Google_Longrunning_Operation) -> Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeResponse? {
        guard operation.response.isA(Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeResponse.self) else { return nil }
        return try? Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeResponse(unpackingAny: operation.response)
    }

    private func pollOperation(withName name: String) -> Google_Longrunning_Operation? {
        var getOpRequest = Google_Longrunning_GetOperationRequest()
        getOpRequest.name = name
        return try? operationsClient.getOperation(getOpRequest)
    }
}

