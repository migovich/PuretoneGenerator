//
//  ViewController.swift
//  PuretoneGenerator
//
//  Created by Migovich on 19.03.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var channelSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var frequencyTextField: UITextField!
    @IBOutlet private weak var durationTextField: UITextField!
    @IBOutlet private weak var fadeInFadeOutTextField: UITextField!
    @IBOutlet private weak var repeatSwitch: UISwitch!
    
    private let player = PuretoneGenerator()
    private let volume: Float = 1
    private var toneTimer: Timer?
    
    private var frequency: Double {
        if let text = frequencyTextField.text,
           let doubleValue = Double(text) {
            return doubleValue
        } else {
            return 1000
        }
    }
    
    private var duration: TimeInterval {
        if let text = durationTextField.text,
           let doubleValue = Double(text) {
            return doubleValue
        } else {
            return 1
        }
    }
    
    private var fadeInFadeOut: TimeInterval {
        if let text = fadeInFadeOutTextField.text,
           let doubleValue = Double(text) {
            return doubleValue
        } else {
            return 250
        }
    }
    
    private var channel: AudioChannel {
        let index = channelSegmentedControl.selectedSegmentIndex
        let channel = AudioChannel(rawValue: index)
        return channel ?? .mono
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        frequencyTextField.text = "\(frequency)"
        durationTextField.text = "\(duration)"
        fadeInFadeOutTextField.text = "\(fadeInFadeOut)"
    }

    // MARK: Actions
    @IBAction private func playButtonPressed(_ sender: UIButton) {
        repeatSwitch.isOn ? scheduleTone(with: 2) : playTone()
    }
    
    @IBAction private func stopButtonPressed(_ sender: UIButton) {
        stopTone()
    }
    
    // MARK: Functions
    private func playTone() {
        player.generateTone(frequency: frequency,
                            volume: volume,
                            duration: duration,
                            fadeInFadeOut: fadeInFadeOut,
                            channel: channel)
        player.playTone()
    }
    
    func scheduleTone(with delay: TimeInterval) {
        player.generateTone(frequency: frequency,
                            volume: volume,
                            duration: duration,
                            fadeInFadeOut: fadeInFadeOut,
                            channel: channel)
        toneTimer?.invalidate()
        toneTimer = Timer.scheduledTimer(withTimeInterval: duration + delay, repeats: true) { [weak self] _ in
            self?.playTone()
        }
    }
    
    private func stopTone() {
        player.stopTone()
        toneTimer?.invalidate()
    }
}
