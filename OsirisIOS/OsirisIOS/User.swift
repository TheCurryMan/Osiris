//
//  User.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import Foundation
import UIKit

class User {
    var action: Action!
    var category: Category!
    var listener = OEEventsObserver()
    var controller = OEPocketsphinxController.sharedInstance()
    static var currentUser = User()
    init() {
        createListener()
    }
    
    func createListener() {
        let lmGenerator = OELanguageModelGenerator()
        let words = ["Learn", "Test", "Numbers", "Letters", "Back"] // These can be lowercase, uppercase, or mixed-case.
        let name = "WordRecognizer"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if err != nil {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
            
            // OELogging.startOpenEarsLogging() //Uncomment to receive full OpenEars logging in case of any unexpected results.
            do {
                try self.controller!.setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
            } catch {
                print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
            }
            
            controller!.startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
            //OEPocketsphinxController.sharedInstance().suspendRecognition()
            //OEPocketsphinxController.sharedInstance().resumeRecognition()
        }
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
