//
//  CamperServiceTests.swift
//  CampgroundManagerTests
//
//  Created by leng on 2021/07/12.
//  Copyright © 2021 Razeware. All rights reserved.
//

import XCTest
import CoreData
import CampgroundManager

class CamperServiceTests: XCTestCase {
	var camperService: CamperService!
	var coreDataStack: CoreDataStack!
	

    override func setUpWithError() throws {
				coreDataStack = TestCoreDataStack()
			  camperService = CamperService(
				 managedObjectContext: coreDataStack.mainContext,
				 coreDataStack: coreDataStack)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
		func testAddCamper() {
			let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
			
			XCTAssertNotNil(camper, "Camper should not be nil")
			XCTAssertTrue(camper?.fullName == "Bacon Lover")
			XCTAssertTrue(camper?.phoneNumber == "910-543-9000")
		}
	
	func testRootContextIsSavedAfterAddingCamper()  {
		
		let derivedContext = coreDataStack.newDerivedContext()
		
		camperService = CamperService(managedObjectContext: derivedContext,coreDataStack: coreDataStack)
		
		expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { _ in
			return true
		}
		
		derivedContext.perform {
			let camper = self.camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
			
			XCTAssertNotNil(camper)
		}
		
		waitForExpectations(timeout: 2.0) { error in
			XCTAssertNil(error, "Save did not occur")
		}
		
		
	}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
