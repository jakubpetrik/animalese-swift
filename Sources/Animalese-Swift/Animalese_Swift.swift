import Foundation

public struct Animalese {
    public let letterLibrary: Data
    public let sampleRate: Double
    public let libraryLetterSeconds: Double
    public let librarySamplesPerLetter: Int
    public let outputLetterSeconds: Double
    public let outputSamplesPerLetter: Int

    public init(letterLibrary: Data, sampleRate: Double, libraryLetterSeconds: Double, outputLetterSeconds: Double) {
        self.letterLibrary = letterLibrary
        self.sampleRate = sampleRate
        self.libraryLetterSeconds = libraryLetterSeconds
        self.outputLetterSeconds = outputLetterSeconds
        librarySamplesPerLetter = Int(floor(libraryLetterSeconds * sampleRate))
        outputSamplesPerLetter = Int(floor(outputLetterSeconds * sampleRate))
    }

    public func synthesize(_ script: String, shortenWords: Bool, pitch: Double) -> Data {
        // https://github.com/Acedio/animalese.js/blob/master/animalese.js
        var processedScript = script
        if shortenWords {
            processedScript = script
                .replacingOccurrences(of: "/[^a-z]/gi", with: " ", options: .regularExpression)
                .split(separator: " ")
                .map(shorten)
                .joined(separator: "")
        }

        var data = Data()
        let dataOffset = 44

        for c in processedScript.uppercased() {
            if (c >= "A" && c <= "Z") {
                let libraryLetterStart = librarySamplesPerLetter * Int(c.asciiValue! - Character("A").asciiValue!)
                for i in 0..<outputSamplesPerLetter {
                    let sampleIndex = dataOffset + libraryLetterStart + Int(floor(Double(i) * pitch))
                    data.append(letterLibrary[sampleIndex])
                }
            } else { // non pronouncable character or space
                for _ in 0..<outputSamplesPerLetter {
                    data.append(127)
                }
            }
        }

        return data.wav(sampleRate: Int32(sampleRate))
    }

    private func shorten(word: String.SubSequence) -> String {
        word.count > 1
            ? "\(word.first!)\(word.last!)"
            : "\(word)"
    }
}

private extension Data {
    func wav(sampleRate: Int32) -> Data {
        // http://soundfile.sapp.org/doc/WaveFormat/
        let dataSize = Int32(count)
        let chunkSize = 36 + dataSize
        let subChunkSize: Int32 = 16
        let format: Int16 = 1
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 8
        let byteRate = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign = channels * bitsPerSample / 8

        var header = Data()
        header.append([UInt8]("RIFF".utf8), count: 4)
        header.append(chunkSize.littleEndianBytes, count: 4)
        header.append([UInt8]("WAVE".utf8), count: 4)
        header.append([UInt8]("fmt ".utf8), count: 4)
        header.append(subChunkSize.littleEndianBytes, count: 4)
        header.append(format.littleEndianBytes, count: 2)
        header.append(channels.littleEndianBytes, count: 2)
        header.append(sampleRate.littleEndianBytes, count: 4)
        header.append(byteRate.littleEndianBytes, count: 4)
        header.append(blockAlign.littleEndianBytes, count: 2)
        header.append(bitsPerSample.littleEndianBytes, count: 2)
        header.append([UInt8]("data".utf8), count: 4)
        header.append(dataSize.littleEndianBytes, count: 4)

        return header + self
    }
}

private extension FixedWidthInteger {
    var littleEndianBytes: [UInt8] {
        withUnsafeBytes(of: littleEndian, Array.init)
    }
}
