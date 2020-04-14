# Animalese-Swift
[![platform](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20watchOS%20|%20tvOS-blue.svg)]()
[![SwiftPM-compatible](https://img.shields.io/badge/SwiftPM-✔-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

A Swift port of https://github.com/Acedio/animalese.js.

### Usage

```swift
import SwiftUI
import AVFoundation
import Animalese_Swift

struct ContentView: View {
    @State var text = "Well, I do have a little musical knowledge..."
    @State var pitch = 1.0
    @State var shortenWords = false
    @State var player: AVAudioPlayer!

    private let synth = Animalese(
        letterLibrary: NSDataAsset(name: "animalese")!.data,
        sampleRate: 44100,
        libraryLetterSeconds: 0.15,
        outputLetterSeconds: 0.075
    )

    var body: some View {
        NavigationView {
            Form {
                TextField("Type here...", text: $text)
                Slider(value: $pitch, in: 0.2...2.0, step: 0.1, minimumValueLabel: Text("😡"), maximumValueLabel: Text("🐹")) {
                    Text("Pitch")
                }
                Toggle(isOn: $shortenWords) {
                    Text("Words shortening")
                }
                Button(action: play) {
                    Text("Play")
                }
            }.navigationBarTitle(Text("Animalese-Swift Demo"))
        }
    }

    func play() {
        let data = synth.synthesize(text, shortenWords: shortenWords, pitch: pitch)
        player = try! AVAudioPlayer(data: data)
        player.play()
    }
}


```

## Installation

### Swift Package Manager

Animalese-Swift is SwiftPM-compatible. To install, add this package to your `Package.swift` or your Xcode project.
