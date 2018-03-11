//
//  ViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
