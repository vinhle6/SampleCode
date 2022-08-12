//
//  SynthViewModel.swift
//  SurgeSport
//
//  Created by Tin Nguyen on 08/08/2022.
//  Copyright © 2022 SurgeSport. All rights reserved.
//

import AVFoundation
import Foundation
import Speech
import SwiftUI

class SynthViewModel: NSObject, ObservableObject {

    private var speechSynthesizer = AVSpeechSynthesizer()
    private var voice: AVSpeechSynthesisVoice?

    @Published var isFinished: Int = 0
    @Published var speechRecognizer = SpeechRecognizer()
    @Published var speechVoices: [String] = AVSpeechSynthesisVoice.speechVoices().map({$0.language})

    override init() {
        super.init()
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer.delegate = self
        voice = AVSpeechSynthesisVoice(language: "ja-JP")
    }

    func speak(text: String, lang: String = "ja-JP") {

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.soloAmbient)
            try audioSession.setMode(AVAudioSession.Mode.spokenAudio)
            let utterance = AVSpeechUtterance(string: text)
            // Configure the utterance.
            utterance.rate = 0.3
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.2
            utterance.volume = 0.8

            utterance.voice = AVSpeechSynthesisVoice(language: lang)
            self.speechSynthesizer.continueSpeaking()
            self.speechSynthesizer.speak(utterance)
//            self.stopEngine()
//            self.startButton.isEnabled = true
//            self.startButton.setTitle("Start", for: .normal)
        } catch {
            print(error)
        }
    }

}
extension SynthViewModel: AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print(true)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print(false)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechRecognizer.transcript = ""
        speechRecognizer.transcribe()
    }
}
