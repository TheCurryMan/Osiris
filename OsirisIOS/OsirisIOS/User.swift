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
    static var currentUser = User()
    init() {
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
