import ArgumentParser
import SpeechRecognitionCore
import Foundation

@main
struct CLI {
   static func main() async {
      await SpeechRecognition.main()
   }
}

struct SpeechRecognition: AsyncParsableCommand {
    
    @Argument
    var file: String
    
    @Option
    var locale: String = "ja-JP"
    
    @Option
    var segentLength: Int = 30
    
    @Flag
    var onDevice: Bool = true
    
    @Argument
    var output: String
    
    func run() async throws {
        let recognizer = SpeechRecognitionCore.SpeechRecognition(
            url: URL(filePath: file),
            localeIdenitifier: locale,
            segmentDuration: Double(segentLength),
            requiresOnDeviceRecognition: onDevice
        )
        let results = try await recognizer.results()
        var outputURL = URL(filePath: output)
        if !outputURL.isFileURL {
            outputURL.append(component: "output.txt")
        }
        
        let content = results
            .map({ "\($0.timeRange.start.seconds): \($0.transcription)" })
            .joined(separator: "\n")
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
        
        print("Saved: \(outputURL)")
    }
}
