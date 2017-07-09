//
//  Task.swift
//  Fitsmind
//
//  Created by Mamun Ar Rashid on 7/9/17.
//  Copyright © 2017 Fantasy Apps. All rights reserved.
//

import UIKit
import RealmSwift

final class Task: Object {
    dynamic var name = ""
    dynamic var date: Date = Date()
    dynamic var isCompleted = false
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
