//
//  PuretoneGenerator.swift
//  PuretoneGenerator
//
//  Created by Migovich on 19.03.2024.
//

import Foundation
import AVFoundation

enum AudioChannel: Int {
    case left
    case right
    case mono
}

class PuretoneGenerator {

    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioBuffer: AVAudioPCMBuffer?

    func generateTone(frequency: Double, volume: Float, duration: TimeInterval, fadeInFadeOut: TimeInterval, channel: AudioChannel) {
        
        let sampleRate = 44100
        let channels = AVAudioChannelCount(2)
        let frames = AVAudioFrameCount(duration * Double(sampleRate))
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: channels)!
        
        audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frames)!
        audioBuffer!.frameLength = frames
        
        let amplitude = volume * 0.25 // Adjust based on your requirement
        
        for frame in 0..<Int(frames) {
            let time = Double(frame) / Double(sampleRate)
            let sampleValue = Float(sin(2 * .pi * frequency * time)) * amplitude
            
            if frame < Int(fadeInFadeOut * Double(sampleRate)) {
                // Fade in logic
                let multiplier = Float(frame) / Float(fadeInFadeOut * Double(sampleRate))
                audioBuffer?.floatChannelData!.pointee[frame] = sampleValue * multiplier
            } else if frame > Int(Double(frames) - fadeInFadeOut * Double(sampleRate)) {
                // Fade out logic
                let multiplier = Float(Int(Double(frames) - fadeInFadeOut * Double(sampleRate)) - frame) / Float(fadeInFadeOut * Double(sampleRate))
                audioBuffer?.floatChannelData!.pointee[frame] = sampleValue * multiplier
            } else {
                audioBuffer?.floatChannelData!.pointee[frame] = sampleValue
            }
            
            switch channel {
            case .left:
                audioBuffer?.floatChannelData![0][frame] = sampleValue
            case .right:
                audioBuffer?.floatChannelData![1][frame] = sampleValue
            case .mono:
                audioBuffer?.floatChannelData![0][frame] = sampleValue
                audioBuffer?.floatChannelData![1][frame] = sampleValue
            }
        }
    }

    func playTone() {
        stopTone()
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine?.attach(audioPlayerNode!)
        audioEngine?.connect(audioPlayerNode!, to: audioEngine!.mainMixerNode, format: audioBuffer?.format)
        audioPlayerNode?.scheduleBuffer(audioBuffer!, completionHandler: nil)
        
        do {
            try audioEngine?.start()
            audioPlayerNode?.play()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func stopTone() {
        if let node = audioPlayerNode {
            node.stop()
        }
        if let engine = audioEngine {
            engine.stop()
            engine.reset()
        }
    }
}
