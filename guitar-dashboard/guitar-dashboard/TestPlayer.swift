//
//  TestPlayer.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 15/07/21.
//

import Foundation
import AVFoundation

class TestPlayer: NSObject, ObservableObject {
    private var audioFile: AVAudioFile?
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let timeEffect = AVAudioUnitTimePitch()
    private var needsFileScheduled = true

    private func scheduleAudioFile() {
      guard
        let file = audioFile,
        needsFileScheduled
      else {
        return
      }

      needsFileScheduled = false
      seekFrame = 0

      player.scheduleFile(file, at: nil) {
        self.needsFileScheduled = true
      }
    }

    private func configureEngine(with format: AVAudioFormat) {
      engine.attach(player)
      engine.attach(timeEffect)

      engine.connect(
        player,
        to: timeEffect,
        format: format)
      engine.connect(
        timeEffect,
        to: engine.mainMixerNode,
        format: format)

      engine.prepare()

      do {
        try engine.start()

        scheduleAudioFile()
                
        player.play()
        //isPlayerReady = true
      } catch {
        print("Error starting the player: \(error.localizedDescription)")
      }
    }

    
    func setup() {
        guard let fileURL = Bundle.main.url(forResource: "Dancing", withExtension: "mp3") else {
          return
        }
        do {
          let file = try AVAudioFile(forReading: fileURL)
          let format = file.processingFormat

          audioLengthSamples = file.length
          audioSampleRate = format.sampleRate
          audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate

          audioFile = file

          configureEngine(with: format)
        } catch {
          print("Error reading the audio file: \(error.localizedDescription)")
        }

    }
}
