//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by leng on 2021/07/08.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
	@NSManaged var dateCreated: Date
	@NSManaged var image: UIImage?
	@NSManaged var note: Note?
}
