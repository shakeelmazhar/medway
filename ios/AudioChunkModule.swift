//
//  AudioChunkModule.swift
//  AudioRecordingApp
//
//  Created by admin on 09/10/2024.
//

import Foundation
import AVFoundation
import React

@objc(AudioChunkModule)
class AudioChunkModule: RCTEventEmitter {

    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    var filePath: String = ""
    let chunkInterval: TimeInterval = 30 // 30 seconds

    @objc
    func startRecording(_ fileName: String) {
        self.filePath = fileName
        startNewRecordingSession(filePath: fileName)
        
        // Schedule a timer to capture chunks every 30 seconds
        timer = Timer.scheduledTimer(timeInterval: chunkInterval, target: self, selector: #selector(captureChunk), userInfo: nil, repeats: true)
    }

    func startNewRecordingSession(filePath: String) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let audioFilename = URL(fileURLWithPath: filePath)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch {
            print("Failed to start recording")
        }
    }

    @objc func captureChunk() {
        audioRecorder?.stop()
        
        // Send chunk to JS side
        sendEvent(withName: "AudioChunkCaptured", body: ["filePath": filePath])

        // Create a new file path for the next chunk
        let newFilePath = "\(filePath)_\(Date().timeIntervalSince1970).m4a"
        startNewRecordingSession(filePath: newFilePath)
    }

    @objc
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
    }

    override func supportedEvents() -> [String]! {
        return ["AudioChunkCaptured"]
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
