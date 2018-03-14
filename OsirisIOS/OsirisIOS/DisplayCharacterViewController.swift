//
//  DisplayCharacterViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class DisplayCharacterViewController: UIViewController, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
    
    var cu = User.currentUser
    
    var synth = AVSpeechSynthesizer()
    var player2 : AVAudioPlayer?
    
    let numData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var listOfNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var letterData = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    var listOfLetters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

    var currentValue: String!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer!.delegate = self
        cu.category = Category.numbers
        synth.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch cu.category! {
        case .numbers:
            self.playText(text: "Let's learn Numbers!")
        case .letters:
            self.playText(text: "Let's learn Letters!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func repeatAudio(_ sender: Any) {
            self.playText(text: "\(currentValue!)")
    }
    
    @IBAction func nextCharacter(_ sender: Any) {
        switch cu.category! {
        case .numbers:
            getNumData()
        case .letters:
            getLetterData()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if utterance.speechString == "Let's learn Numbers!" {
            getNumData()
        } else if utterance.speechString == "Let's learn Letters!" {
            getLetterData()
        }
    }
    
    func getNumData() {
        if listOfNums.count == 0 {
            listOfNums = numData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfNums.count)))
        currentValue = "\(listOfNums[randomIndex])"
        makeRequest()
        self.listOfNums.remove(at: randomIndex)
        self.playText(text: "\(currentValue!)")
    }
    
    func getLetterData() {
        if listOfLetters.count == 0 {
            listOfLetters = letterData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfLetters.count)))
        currentValue = "\(listOfLetters[randomIndex])"
        makeRequest()
        self.listOfLetters.remove(at: randomIndex)
        self.playText(text: "\(currentValue!)")
    }
    
    func makeRequest() {
        let urlString = URL(string: "http://osiris1.herokuapp.com/?character=" + currentValue!) //change the url
        
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error ?? "")
                } else {
                    if let responceData = data {
                        print(responceData) //JSONSerialization
                    }
                }
            }
            task.resume()
        }
    }
    
    func playText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
    
    func analyzeResult(_ hypothesis: String!) { // Something was heard
        if button.isHidden != true {
            if hypothesis! == "Repeat" {
                repeatAudio(self)
                button.isHidden = true
            } else if hypothesis! == "Next" {
                nextCharacter(self)
                button.isHidden = true
            }
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
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("Motion Began")
        startRecording()
        addButton()
        button.isHidden = false
        
    }
    
    

}
