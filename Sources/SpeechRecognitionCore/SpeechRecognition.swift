import Foundation
import AVFoundation
@preconcurrency import Speech

package struct SpeechRecognitionResult: Sendable, CustomStringConvertible {
    package let timeRange: CMTimeRange
    package let transcription: String
    
    package var description: String {
        "\(timeRange.start.formatted()) \(transcription)"
    }
}

package struct SpeechRecognition {
    let url: Foundation.URL
    let localeIdenitifier: String
    let segmentDuration: Double
    let requiresOnDeviceRecognition: Bool
    
    package init(
        url: Foundation.URL,
        localeIdenitifier: String = "ja-JP",
        segmentDuration: Double = 60,
        requiresOnDeviceRecognition: Bool
    ) {
        self.url = url
        self.localeIdenitifier = localeIdenitifier
        self.segmentDuration = segmentDuration
        self.requiresOnDeviceRecognition = requiresOnDeviceRecognition
    }
    
    package func results() -> AsyncThrowingStream<SpeechRecognitionResult, any Error> {
        let (stream, continuation) = AsyncThrowingStream<SpeechRecognitionResult, any Error>.makeStream()
        Task {
            let asset = AVURLAsset(url: url)
            let locale = Locale(identifier: localeIdenitifier)
            let recognizer = SFSpeechRecognizer(locale: locale)!
            recognizer.defaultTaskHint = .dictation
            
            let duration = try await asset.load(.duration)
            let segmentDuration = CMTime(
                seconds: segmentDuration,
                preferredTimescale: duration.timescale
            )
            var currentStartTime = CMTime.zero
            
            var progressBar = ProgressBar(output: FileHandle.standardOutput)

            while currentStartTime < duration {
                let total = CMTimeGetSeconds(duration)
                let step = CMTimeGetSeconds(currentStartTime)
                progressBar.render(count: Int(step), total: Int(total))
                
                let currentEndTime = CMTimeMinimum(currentStartTime + segmentDuration, duration)
                let timeRange = CMTimeRange(start: currentStartTime, end: currentEndTime)

                let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
                exporter.timeRange = timeRange
                let segmentURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("segment.m4a")

                try? FileManager.default.removeItem(at: segmentURL)
                try await exporter.export(to: segmentURL, as: .m4a)
                
                let request = SFSpeechURLRecognitionRequest(url: segmentURL)
                request.requiresOnDeviceRecognition = requiresOnDeviceRecognition
                request.shouldReportPartialResults = false
                
                do {
                    let transcription = try await recognizer.result(with: request)
                    let result = SpeechRecognitionResult(
                        timeRange: timeRange,
                        transcription: transcription
                    )
                    continuation.yield(result)
                } catch {
                    
                }

                try? FileManager.default.removeItem(at: segmentURL)

                currentStartTime = currentEndTime
            }
            
            progressBar.finish()
            continuation.finish()
        }
        return stream
    }
}

