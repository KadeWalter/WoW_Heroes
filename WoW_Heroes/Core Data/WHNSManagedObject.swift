//
//  GenericNSManagedObject.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 8/5/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit
import CoreData

enum GenericNSManageObjectError: Error {
    case managedObjectContextError
}

class WHNSManagedObject: NSManagedObject {
    
    // identifier used for generics when getting entity names
    class func identifier() -> String {
        return ""
    }
    
    required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Function for getting managed object context
    class func WHManagedObjectContext() -> NSManagedObjectContext {
        return AppDelegate.delegate().persistentContainer.viewContext
    }
    
    // Insert Functions
    func insert(intoContext context: NSManagedObjectContext) {
        context.insert(self)
    }
    
    class func createWithoutInsert(context: NSManagedObjectContext) -> Self? {
        guard let entity = NSEntityDescription.entity(forEntityName: self.identifier(), in: context) else { return nil }
        return self.init(entity: entity, insertInto: nil)
    }
}
