//
//  ContentView.swift
//  Shared
//
//  Created by Vinh Le on 8/10/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var synthViewModel = SynthViewModel()
    @State var timer = Timer.publish(every: 5, on: .main, in: .common)
    @State var timeRemaining: Double = 5
    @State var text: String = "Hello"
    @State var languageId: String = "ar-SA"
    
    var body: some View {
        Form {
            Section{
                Text(text)
                    .padding()
                    .onReceive(timer, perform: { _ in
                        print("\(timeRemaining)")
                        if timeRemaining > 0{
                            timeRemaining -= 1
                        } else {
                            endRecordWithText()
                            if synthViewModel.speechRecognizer.transcript.isEmpty{
                                startRecordingWithText(text: "No speech detected, Please try it again.", lang: languageId)
                                print("Starting record .......")
                            } else {
                                text = synthViewModel.speechRecognizer.transcript
                                if text.lowercased().contains("yes"){
                                    print("Ending conversation")
                                } else if text.lowercased().contains("no"){
                                    startRecordingWithText(text: "Please set weight", lang: languageId)
                                } else {
                                    startRecordingWithText(text: "Are you sure \(text) is your weight", lang: languageId)
                                }
                            }
                        }
                    })
                    .onChange(of: synthViewModel.speechRecognizer.transcript, perform: { _ in
                        print("has recoginition with text: \(synthViewModel.speechRecognizer.transcript)")
                    })
                    .onAppear{
                        startRecordingWithText(text: "Please set weight", timeInt: 5, lang: languageId)
                    }
            }
            Section {
                Picker("Strength", selection: $languageId) {
                    ForEach(synthViewModel.speechVoices, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
    
    func startRecordingWithText(text: String, timeInt: Double = 3, lang: String){
        synthViewModel.speak(text: text, lang: lang)
        timeRemaining = timeInt
        timer = Timer.publish(every: timeInt, on: .main, in: .common)
        timer.connect()
    }
    
    func endRecordWithText(){
        timer.connect().cancel()
        synthViewModel.speechRecognizer.stopTranscribing()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
