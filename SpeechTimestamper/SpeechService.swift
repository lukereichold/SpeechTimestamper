import Foundation
import SwiftGRPC

typealias RecognitionResult = Google_Cloud_Speech_V1p1beta1_SpeechRecognitionResult
typealias SpeechServiceCompletion = (SpeechServiceResponse) -> (Void)

enum SpeechServiceResponse {
    case success([RecognitionResult])
    case failure(Error)
}

final class SpeechService {
    private var speechClient: Google_Cloud_Speech_V1p1beta1_SpeechServiceClient!
    private var operationsClient: Google_Longrunning_OperationsServiceClient!
    var sampleRate: Int = 12000
    
    static let shared = SpeechService()
    
    private init() {
        speechClient = Google_Cloud_Speech_V1p1beta1_SpeechServiceClient(address: "speech.googleapis.com")
        speechClient.metadata = try! Metadata(["x-goog-api-key": Keys.readGcpKey()])
        
        operationsClient = Google_Longrunning_OperationsServiceClient(address: "speech.googleapis.com")
        operationsClient.metadata = try! Metadata(["x-goog-api-key": Keys.readGcpKey()])
    }

    func transcribeAudioData(_ audioData: Data,
                             completion: @escaping SpeechServiceCompletion) {
        
        var recognitionConfig = Google_Cloud_Speech_V1p1beta1_RecognitionConfig()
        recognitionConfig.encoding = .flac // linear16 otherwise
        recognitionConfig.sampleRateHertz = Int32(sampleRate)
        recognitionConfig.languageCode = "zh-cmn"
        recognitionConfig.enableWordTimeOffsets = true
        
        var audio = Google_Cloud_Speech_V1p1beta1_RecognitionAudio()
        audio.content = audioData
        
        var longRunningRequest = Google_Cloud_Speech_V1p1beta1_LongRunningRecognizeRequest()
        longRunningRequest.config = recognitionConfig
        longRunningRequest.audio = audio

        do {
            _ = try speechClient.longRunningRecognize(longRunningRequest) { (longRunningOperation, callResult) in
                
                guard callResult.success else {
                    completion(.failure(callResult.description))
                    return
                }
                
                DispatchQueue.global().async {
                    var operation: Google_Longrunning_Operation = longRunningOperation!
                    repeat {
                        if let op = self.pollOperation(withName: operation.name) {
                            operation = op
                        }
                    } while !operation.done
                    
                    self.handleCompletedOperation(operation, then: completion)
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
}

extension SpeechService {
    
    private func handleCompletedOperation(_ operation: Google_Longrunning_Operation, then completion: SpeechServiceCompletion) {
        debugPrint("Error: \(operation.error)")
        if let metadata = unpackMetadata(forOperation: operation) {
            debugPrint("==== Metadata ====", metadata)
        }
        
        if let results = unpackResponse(forOperation: operation)?.results {
            completion(.success(results))
        } else {
            completion(.failure(operation.error.message))
        }
    }
    
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

extension String: Error {}
