//
//  ViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OEEventsObserverDelegate {
    
    
    var cu = User.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        requestMicrophoneAccess()
        cu.listener.delegate = self
        
        
    }
    
    func requestMicrophoneAccess() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                print("\(granted)")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
    }

    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        print("Listening...") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Understanding...") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        print("Stopping Listening") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.") // Log it.
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking") // Log it.
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)") // Log it.
    }
    
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
    }
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
    
    func micPermissionCheckCompleted(withResult: Bool) {
        print("Local callback: mic check completed.")
    }
    

    @IBAction func learnPressed(_ sender: Any) {
        User.currentUser.action = .learn
        performSegue(withIdentifier: "cat", sender: self)
    }
    @IBAction func testPressed(_ sender: Any) {
        User.currentUser.action = .test
        performSegue(withIdentifier: "cat", sender: self)
    }
}
