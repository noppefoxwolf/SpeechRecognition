import Speech

extension SFSpeechRecognizer {
    func result(with request: SFSpeechRecognitionRequest) async throws -> String {
        var iterator = results(with: request).makeAsyncIterator()
        return try await iterator.next()!
    }

    func results(with request: SFSpeechRecognitionRequest) -> AsyncThrowingStream<String, any Error> {
        AsyncThrowingStream { continuation in
            recognitionTask(with: request) { result, error in
                if let error {
                    continuation.finish(throwing: error)
                } else if let result {
                    continuation.yield(result.bestTranscription.formattedString)
                } else {
                    fatalError("予期せぬ結果")
                }
            }
        }
    }
}
