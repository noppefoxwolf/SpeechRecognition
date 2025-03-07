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
    var onDevice: Bool = false
    
    @Argument
    var output: String
    
    func run() async throws {
        var outputURL = URL(filePath: output)
        if !outputURL.isFileURL {
            outputURL.append(component: "output.txt")
        }
        
        var outputStream = OutputStream(url: outputURL, append: true)!
        outputStream.open()
        defer {
            outputStream.close()
        }
        
        let recognizer = SpeechRecognitionCore.SpeechRecognition(
            url: URL(filePath: file),
            localeIdenitifier: locale,
            segmentDuration: Double(segentLength),
            requiresOnDeviceRecognition: onDevice
        )
        for try await result in recognizer.results() {
            outputStream.write(result.description)
            outputStream.write("\n")
        }
        
        print("Saved: \(outputURL)")
    }
}

