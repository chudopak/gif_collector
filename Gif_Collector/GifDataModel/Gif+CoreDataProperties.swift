//
//  Gif+CoreDataProperties.swift
//  
//
//  Created by Stepan Kirillov on 12/27/21.
//
//

import Foundation
import CoreData


extension Gif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gif> {
        return NSFetchRequest<Gif>(entityName: "Gif")
    }

    @NSManaged public var gifData: Data?
    @NSManaged public var gifPixelHeight: Int32
    @NSManaged public var gifPixelWidth: Int32
    @NSManaged public var date: Date

}
