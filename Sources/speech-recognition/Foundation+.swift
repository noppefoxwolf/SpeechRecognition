import Foundation

extension OutputStream {
    func write(_ string: String) {
        let data = string.data(using: .utf8)!
        data.withUnsafeBytes {
            let buffer = $0.baseAddress!.assumingMemoryBound(to: UInt8.self)
            write(buffer, maxLength: data.count)
        }
    }
}
