//
//  SoundPlayerViewController.swift
//  Pitch-Perfect-II
//
//  Created by Patrizio Palazzetti on 17/10/15.
//  Copyright © 2015 Patrizio Palazzetti. All rights reserved.
//

import UIKit
import AVFoundation

class SoundPlayerViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var stopPlayingButton: UIButton!
    
    // MARK: - Enumerations
    private enum SoundEffect {
        case Speed (Float)
        case Pitch (Float)
        case Distortion (Float)
        case Reverb (Float)
    }
        
    // MARK: - Variables
    internal var receivedAudio: RecordedAudio?
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        audioEngine = AVAudioEngine()
        
        do {
            if let audio = receivedAudio {
                audioFile = try AVAudioFile(forReading: audio.filePath)
            }
        } catch let error as NSError {
            print("An error occurred trying to open the audio file. ERROR: \(error.localizedDescription)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func playHigh(sender: UIButton) {
        
        playWithEffect(effect: .Pitch(1000.0))
        
    }
    
    @IBAction func playLow(sender: UIButton) {
        
        playWithEffect(effect: .Pitch(-1000.0))

    }
    
    @IBAction func playFast(sender: UIButton) {
        
        playWithEffect(effect: .Speed(1.5))
        
    }
    
    @IBAction func playSlow(sender: UIButton) {
        
        playWithEffect(effect: .Speed(0.5))
        
    }
    
    @IBAction func playWithDistortion(sender: UIButton) {
        
        playWithEffect(effect: .Distortion(50.0))
        
    }
    
    @IBAction func playWithReverb(sender: UIButton) {
        
        playWithEffect(effect: .Reverb(50.0))
        
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        
        if let engine = audioEngine {
            engine .stop()
        }
    }
    
    // MARK: - Methods
    
//    @objc private func audioEngineConfigurationChange(notification: NSNotification) -> Void {
//        NSLog("We have been notified")
//    }
    
    /// playWithEffects: Play sound with a predefined effect.
    /// - Parameter effect: enum SoundEffect
    /// - Returns: Void
    private func playWithEffect(effect effect: SoundEffect) -> Void {
        
        if let engine = audioEngine {
            
            
            let audioPlayerNode = AVAudioPlayerNode()
            
            engine.stop()
            engine.reset()
            
            engine.attachNode(audioPlayerNode)
            
            // Downcasting to the first common object of AVAudioUnitTimePitch, AVAudioUnitDistortion & AVAudioUnitReverb
            let changeSoundEffect: AVAudioUnit?
            
            // Creating the correct effect node
            switch effect {
            case let .Speed(value):
                changeSoundEffect = AVAudioUnitTimePitch()
                (changeSoundEffect as! AVAudioUnitTimePitch).rate = value
            case let .Pitch(value):
                changeSoundEffect = AVAudioUnitTimePitch()
                (changeSoundEffect as! AVAudioUnitTimePitch).pitch = value
            case let .Distortion(value):
                changeSoundEffect = AVAudioUnitDistortion()
                (changeSoundEffect as! AVAudioUnitDistortion).loadFactoryPreset(AVAudioUnitDistortionPreset.SpeechRadioTower)
                (changeSoundEffect as! AVAudioUnitDistortion).wetDryMix = value
            case let .Reverb(value):
                changeSoundEffect = AVAudioUnitReverb()
                (changeSoundEffect as! AVAudioUnitReverb).loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
                (changeSoundEffect as! AVAudioUnitReverb).wetDryMix = value
            }
            
            // Attaching node to audio engine
            engine.attachNode(changeSoundEffect!)
            
            // Connecting nodes
            engine.connect(audioPlayerNode, to: changeSoundEffect!, format: nil)
            engine.connect(changeSoundEffect!, to: engine.outputNode, format: nil)
            
            // Assign audio to player
            if let aFile = audioFile {
                audioPlayerNode.scheduleFile(aFile, atTime: nil, completionHandler: nil)
            }
            
            // Start audio engine
            engine.prepare()
            
            do {
                try engine.start()
            } catch let error as NSError {
                print("An error ocurred trying to start audioEngine. ERROR: \(error.localizedDescription)")
            }
            
            // Start playing audio
            audioPlayerNode.play()
        }
    }
}
