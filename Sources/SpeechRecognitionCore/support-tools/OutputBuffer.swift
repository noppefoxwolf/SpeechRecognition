import Foundation

public protocol OutputBuffer {
    mutating func write(_ text: String)
    mutating func clearLine()
}

extension FileHandle: OutputBuffer {
    public func write(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        write(data)
    }
    
    public func clearLine() {
        write("\r")
    }
}
