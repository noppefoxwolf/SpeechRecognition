import CoreMedia

extension CMTime {
    func formatted() -> String {
        let totalSeconds = CMTimeGetSeconds(self)
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

