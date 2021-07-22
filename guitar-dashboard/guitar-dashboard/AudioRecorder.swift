//
//  AudioRecorder.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 17/07/21.
//

import Foundation
import AVFoundation

class AudioRecorder {
    enum RecordingState {
        case recording, paused, stopped
    }
    
    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    private var inputNode: AVAudioInputNode!
    private var state: RecordingState = .stopped
    private var bufferData: [(UInt32, Int)] = []
    private var sampleBuffer: [Float] = []
    
    var debugText: String
    
    init() {
        debugText = "debugText";
        setupSession()
        setupEngine()
    }
    
    fileprivate func setupSession() {
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        let availableInputs = session.availableInputs
            
    }
    
    fileprivate func setupEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        //         Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0
        
        engine.attach(mixerNode)
        
        makeConnections()
        
        // Prepare the engine in advance, in order for the system to allocate the necessary resources.
        engine.prepare()
    }
    
    fileprivate func makeConnections() {
        inputNode = engine.inputNode
        
        let mainMixerNode = engine.mainMixerNode
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        self.debugText = "\(inputNode.numberOfInputs) \(inputFormat.sampleRate) \(inputFormat.channelCount) \(inputFormat.streamDescription)"
        
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
    
    func startRecording() throws {
        //        let tapNode: AVAudioNode = mixerNode
        //        let format = tapNode.outputFormat(forBus: 0)
        //
        //        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
        // So we're using the caf file extension.
        //        let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent("recording.caf"), settings: format.settings)
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format, block: {
            (buffer, time) in
            
            if let pointerToPointer = buffer.floatChannelData {
                let pointerToSamples = pointerToPointer[0];
                for index in 0..<buffer.frameLength {
                    let sample: Float = pointerToSamples[Int(index)];
                    self.sampleBuffer.append(sample)
                }
            }
            
            
            
            if self.bufferData.count < 100 {
                self.bufferData.append((buffer.frameLength, buffer.stride))
            }
            //            try? file.write(from: buffer)
            
        })
        
        try engine.start()
        state = .recording
        
    }
    
    func resumeRecording() throws {
        try engine.start()
        state = .recording
    }
    
    func pauseRecording() {
        engine.pause()
        state = .paused
    }
    
    func stopRecording() {
        // Remove existing taps on nodes
        mixerNode.removeTap(onBus: 0)
        
        engine.stop()
        state = .stopped
    }
    
    func getInfo() -> String {
        for element in bufferData {
            print("\(element.0) \(element.1)")
        }
        return bufferData.isEmpty ? "Empty" : "\(bufferData[0].0) \(bufferData[0].1)"
    }
    
}
