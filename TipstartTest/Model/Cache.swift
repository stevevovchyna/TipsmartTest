//
//  Item.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 01.02.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import CoreData

public class Cache : NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var nameCache: Data?
    @NSManaged public var ratingCache: Data?

}
