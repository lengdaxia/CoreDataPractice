//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by leng on 2021/07/08.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

class ImageAttachment: Attachment {
	@NSManaged override var image: UIImage?
	@NSManaged var width: Float
	@NSManaged var height: Float
	@NSManaged var caption: String
}
