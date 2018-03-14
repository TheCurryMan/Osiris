//
//  SelectionViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit
import Speech

class SelectionViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {

    var cu = User.currentUser
    var synth = AVSpeechSynthesizer()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer!.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        synth.delegate = self
        self.playText(text: "Select either numbers or letters")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numbersPressed(_ sender: Any) {
        User.currentUser.category = .numbers
        if cu.action == Action.learn {
            performSegue(withIdentifier: "display", sender: self)
        } else {
            performSegue(withIdentifier: "test", sender: self)
        }
    }
    
    @IBAction func lettersPressed(_ sender: Any) {
        User.currentUser.category = .letters
        if cu.action == Action.learn {
            performSegue(withIdentifier: "display", sender: self)
        } else {
            performSegue(withIdentifier: "test", sender: self)
        }
    }
    
    func playText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
    
    func analyzeResult(_ hypothesis: String!) { // Something was heard
        if hypothesis! == "Numbers" {
            numbersPressed(self)
        } else if hypothesis! == "Letters" {
            lettersPressed(self)
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                let text = (result?.bestTranscription.formattedString)
                print(text!)
                isFinal = (result?.isFinal)!
                self.analyzeResult(text!)
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func addButton() {
        button.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        button.backgroundColor = UIColor.white
        button.setTitle("Listening...", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(doneListening), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func doneListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            button.isHidden = true
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("Motion Began")
        startRecording()
        addButton()
        button.isHidden = false
        
    }
}
