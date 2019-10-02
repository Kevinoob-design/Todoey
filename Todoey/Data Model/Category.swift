//
//  Category.swift
//  Todoey
//
//  Created by Hector Morales veloz on 10/1/19.
//  Copyright © 2019 Hector Morales veloz. All rights reserved.
//

import Foundation
import RealmSwift

/**
    This is the parent Class of Items
 */
class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
