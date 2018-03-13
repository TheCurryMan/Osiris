//
//  User.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class User {
    var action: Action!
    var category: Category!
    
    var player: AVAudioPlayer?
    
    static var currentUser = User()
    init() {
    }
    
    func createListener(listOfWords: [String]) {
        let lmGenerator = OELanguageModelGenerator()
        let name = "WordRecognizer"
        let err: Error! = lmGenerator.generateLanguageModel(from: listOfWords, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if err != nil {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
            OEPocketsphinxController.sharedInstance().vadThreshold = 3.5
            do {
                try OEPocketsphinxController.sharedInstance().setActive(true)
            } catch {
                print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
            }
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
    
    func playSound(text: String, synth: AVSpeechSynthesizer) {
        OEPocketsphinxController.sharedInstance().stopListening()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
        OEPocketsphinxController.sharedInstance().resumeRecognition()
    }
    
    func playFile(name: String) {
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        OEPocketsphinxController.sharedInstance().resumeRecognition()
        
    }
}

    

enum Action {
    case learn
    case test
}

enum Category {
    case numbers
    case letters
}
