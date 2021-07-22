//
//  ContentView.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 14/07/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    private var audioRecorder: AudioRecorder
    @State private var textMessage: String = "defaultText"
    @State private var infoMessage: String = "Info"

    
    init() {
        audioRecorder = AudioRecorder()
    }
    
    var body: some View {
        VStack {
            Text(textMessage)
                .padding()
            Button("Start Recording") {
                try! audioRecorder.startRecording()
            }
            Button("Stop Recording") {
                audioRecorder.stopRecording()
                textMessage = "Stopped"
            }
            Button("Update") {
                textMessage = audioRecorder.debugText
            }
            Button("Get Info") {
                infoMessage = audioRecorder.getInfo()                
            }
            Text(infoMessage)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
