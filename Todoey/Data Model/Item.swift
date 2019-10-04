//
//  Item.swift
//  Todoey
//
//  Created by Hector Morales veloz on 10/1/19.
//  Copyright © 2019 Hector Morales veloz. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var tittle: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
