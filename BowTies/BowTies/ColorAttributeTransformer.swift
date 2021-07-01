//
//  ColorAttributeTransformer.swift
//  BowTies
//
//  Created by leng on 2021/07/01.
//  Copyright © 2021 Razeware. All rights reserved.
//

import UIKit

class ColorAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
	
	override class var allowedTopLevelClasses: [AnyClass]{
		[UIColor.self]
	}
	
	static func register(){
		let className = String(describing: ColorAttributeTransformer.self)
		let name = NSValueTransformerName(className)
		
		let transformer = ColorAttributeTransformer()
		ValueTransformer.setValueTransformer(
				 transformer, forName: name)
	}
	
}
