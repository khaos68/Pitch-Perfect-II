//
//  RecorderViewController.swift
//  Pitch-Perfect-II
//
//  Created by Patrizio Palazzetti on 17/10/15.
//  Copyright © 2015 Patrizio Palazzetti. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: Outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // MARK: - Constants & Variables
    private let textColor: UIColor = UIColor(red: 8.0 / 255.0, green: 63.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0) // Color used for the text
    private var audioRecorder: AVAudioRecorder?
    private var recordedAudio: RecordedAudio?
    private var areWeOK: Bool = true // Boolean variable to keep track of all checks
    
    // MARK: - Enumerators
    private enum UIStates {
        case Ready
        case Recording
        case Paused
        case Error
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Obtain file path
        let soundFileURL = urlFor("sound.caf")
        
        // Set recording setting
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        // Create an audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        // Request permissions
        audioSession.requestRecordPermission({(granted: Bool)->Void in
            if granted == true {
                do {
                    // withOption for route sound to speaker, without this it will be routed to the small speaker for on ear use
                    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
                } catch {
                    self.areWeOK = false
                    print("Unable to create an audio session")
                }
                // Create audio recorder
                do {
                    try self.audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings as! [String: AnyObject])
                    self.audioRecorder?.prepareToRecord()
                    self.audioRecorder?.delegate = self
                } catch {
                    self.areWeOK = false
                    print("Cant create audioRecorder")
                }
            } else {
                self.areWeOK = false
                print ("No permissions granted")
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if areWeOK == true {
            setUIState(.Ready)
        } else {
            setUIState(.Error)
            setMessage("·an error ocurred·", error: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showPlayerSegue") {
            let soundPlayerVC: SoundPlayerViewController = segue.destinationViewController as! SoundPlayerViewController
            let data = sender as! RecordedAudio
            soundPlayerVC.receivedAudio = data
        }
    }
    
    // MARK: - Actions
    
    // Tap record button
    @IBAction func recordSound(sender: UIButton) {
        
        if let recorder = audioRecorder {
            if recorder.recording == false {
                
                setUIState(.Recording)
                
                recorder.prepareToRecord()
                recorder.record()
            }
        }
        
    }

    // Tap pause button
    @IBAction func pauseRecording(sender: UIButton) {
        
        if let recorder = audioRecorder {
            setUIState(.Paused)
            recorder.pause()
        }
        
    }
    
    // Tap stop button
    @IBAction func stopRecording(sender: UIButton) {
        
        if let recorder = audioRecorder {
            // Not need to change UI state, change to player view follows
            recorder.stop()
        }
        
    }
    
    // MARK: - Methods
    
    /// urlFor: Returns an NSURL with the path of the specified file name
    /// - Parameter fileName: String. Name of the file for which the path should be returned
    /// - Returns: NSURL. The path of the file.
    func urlFor (fileName: String) -> NSURL {
        
        let dirs: [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let dir = dirs[0]
        let fileURL = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
        return fileURL
    }
    
    /// setUIState: Modified the condition of the different elements of the UI
    /// - Parameter UIState: Enum. The UI state to change the UI to.
    /// - Returns: Void
    private func setUIState(UIState: UIStates) -> Void {
        
        switch UIState {
        case .Ready:
            setStateForUIButtons(recordButton: true, stopButton: false, pauseButton: false)
            setVisibilityForButtons(stopButton: false, pauseButton: false)
            setMessage("·tap to record·", error: false)
        case .Recording:
            setStateForUIButtons(recordButton: false, stopButton: true, pauseButton: true)
            setVisibilityForButtons(stopButton: true, pauseButton: true)
            setMessage("·recording·", error: false)
        case .Paused:
            setStateForUIButtons(recordButton: true, stopButton: true, pauseButton: false)
            setVisibilityForButtons(stopButton: true, pauseButton: true)
            setMessage("·paused: tap to resume·", error: false)
        case .Error:
            setStateForUIButtons(recordButton: false, stopButton: false, pauseButton: false)
            setVisibilityForButtons(stopButton: false, pauseButton: false)
            setMessage("·an error ocurred·", error: true)
        }
    }

    /// setStateForUIButtons: Set the enabled state for the 4 UI buttons: record, play, stop and pause
    /// - Parameter recordButton: Bool. Define if the record button must be shown.
    /// - Parameter playButton: Bool. Define if the play button must be shown.
    /// - Parameter stopButton: Bool. Define if the stop button must be shown.
    /// - Parameter pauseButton: Bool. Define if the pause button must be shown.
    /// - Returns: Void
    func setStateForUIButtons(recordButton recordButton: Bool, stopButton: Bool, pauseButton: Bool) -> Void {
        
            self.recordButton.enabled = recordButton
            self.stopButton.enabled = stopButton
            self.pauseButton.enabled = pauseButton
        
    }
    
    /// setVisibilityForButtons: Set the hidden state for the UI buttons: stop and pause.
    /// - Parameter stopButton: Bool. True to show the stop button, false to hide it.
    /// - Parameter pauseButton: Bool. True to show the pause button, false to hide it.
    /// - Returns: Void.
    func setVisibilityForButtons(stopButton stopButton: Bool, pauseButton: Bool) -> Void {
        
        self.stopButton.hidden = !stopButton
        self.pauseButton.hidden = !pauseButton

    }

    /// setMessage: Set the message for the main label.
    /// - Parameter message: String. The message to be shown.
    /// - Parameter error: Bool. If the message is an error one. Cause to show the message in red color.
    /// - Returns: Void.
    func setMessage(message: String, error: Bool) -> Void {
        
        messageLabel.text = message
        
        if error == true {
            messageLabel.textColor = UIColor.redColor()
        } else {
            messageLabel.textColor = textColor
        }
    }
    
    // MARK: - Delegates
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag == true {
            
            if let recorder = audioRecorder {
                // Create a RecordedAudio object with path and title of the sound file
                recordedAudio = RecordedAudio(filePath: recorder.url, title: recorder.url.lastPathComponent!)
            }
            
            self.performSegueWithIdentifier("showPlayerSegue", sender: recordedAudio)
            
        } else {
            
            setUIState(.Error)
            setMessage("·error recording·", error: true)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        
        setUIState(.Error)
        setMessage("·error recording·", error: true)
    }
}







