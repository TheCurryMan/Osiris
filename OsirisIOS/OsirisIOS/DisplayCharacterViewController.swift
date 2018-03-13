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

class DisplayCharacterViewController: UIViewController, AVSpeechSynthesizerDelegate, OEEventsObserverDelegate, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer!.delegate = self
        cu.category = Category.numbers
        synth.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch cu.category! {
        case .numbers:
            cu.playSound(text: "Let's learn Numbers!", synth: synth)
        case .letters:
            cu.playSound(text: "Let's learn Letters!", synth: synth)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
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
                
                print(result?.bestTranscription.formattedString)
                isFinal = (result?.isFinal)!
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
        
        //textView.text = "Say something, I'm listening!"
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func repeatAudio(_ sender: Any) {
            cu.playSound(text: "\(currentValue)", synth: synth)
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
 
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        if hypothesis == "Repeat" {
            repeatAudio(self)
        } else if hypothesis == "Next" {
            nextCharacter(self)
        } else if hypothesis == "Back" {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func getNumData() {
        if listOfNums.count == 0 {
            listOfNums = numData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfNums.count)))
        currentValue = "\(listOfNums[randomIndex])"
        //makeRequest()
        self.listOfNums.remove(at: randomIndex)
        self.getAudio(name: currentValue!)
    }
    
    func getLetterData() {
        if listOfLetters.count == 0 {
            listOfLetters = letterData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfLetters.count)))
        currentValue = "\(listOfLetters[randomIndex])"
        makeRequest()
        self.listOfLetters.remove(at: randomIndex)
        cu.playSound(text: currentValue!, synth: synth)
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
    
    func getAudio(name: String) {
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player2 = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            player2!.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player2!.stop()
        player2 = nil
        OEPocketsphinxController.sharedInstance().resumeRecognition()
    }
    
    

}
