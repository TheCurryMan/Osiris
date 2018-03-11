//
//  DisplayCharacterViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit
import AVFoundation

class DisplayCharacterViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    var curUser = User.currentUser
    let numData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var listOfNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var letterData = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    var listOfLetters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

    var currentValue: String!
    var synth = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        synth.delegate = self
        switch curUser.category! {
        case .numbers:
            playSound(text: "Let's learn Numbers!")
        case .letters:
            playSound(text: "Let's learn Letters!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func repeatAudio(_ sender: Any) {
        playSound(text: currentValue!)
    }
    
    @IBAction func nextCharacter(_ sender: Any) {
        switch curUser.category! {
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
    
    func playSound(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
    
    func getNumData() {
        if listOfNums.count == 0 {
            listOfNums = numData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfNums.count)))
        currentValue = "\(listOfNums[randomIndex])"
        makeRequest()
        self.listOfNums.remove(at: randomIndex)
        playSound(text: currentValue!)
    }
    
    func getLetterData() {
        if listOfLetters.count == 0 {
            listOfLetters = letterData
        }
        let randomIndex = Int(arc4random_uniform(UInt32(listOfLetters.count)))
        currentValue = "\(listOfLetters[randomIndex])"
        makeRequest()
        self.listOfLetters.remove(at: randomIndex)
        playSound(text: currentValue!)
    }
    
    func makeRequest()  {
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

}
