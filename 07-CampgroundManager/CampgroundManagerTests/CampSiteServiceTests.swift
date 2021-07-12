//
//  CampSiteServiceTests.swift
//  CampgroundManagerTests
//
//  Created by leng on 2021/07/12.
//  Copyright © 2021 Razeware. All rights reserved.
//
import UIKit
import XCTest
import CampgroundManager
import CoreData

class CampSiteServiceTests: XCTestCase {

	// MARK: Properties
	var campSiteService: CampSiteService!
	var coreDataStack: CoreDataStack!

	override func setUp() {
		super.setUp()

		coreDataStack = TestCoreDataStack()
		campSiteService = CampSiteService(
			managedObjectContext: coreDataStack.mainContext,
			coreDataStack: coreDataStack)
	}
	
	func testAddCampSite() {
		let campSite = campSiteService.addCampSite(
			1,
			electricity: true,
			water: true)

		XCTAssertTrue(
			campSite.siteNumber == 1,
			"Site number should be 1")
		XCTAssertTrue(
			campSite.electricity!.boolValue,
			"Site should have electricity")
		XCTAssertTrue(
			campSite.water!.boolValue,
			"Site should have water")
	}
	
	func testRootContextIsSavedAfterAddingCampsite() {
		let derivedContext = coreDataStack.newDerivedContext()

		campSiteService = CampSiteService(
			managedObjectContext: derivedContext,
			coreDataStack: coreDataStack)

		expectation(
			forNotification: .NSManagedObjectContextDidSave,
			object: coreDataStack.mainContext) { _ in
				return true
		}

		derivedContext.perform {
			let campSite = self.campSiteService.addCampSite(
				1,
				electricity: true,
				water: true)
			XCTAssertNotNil(campSite)
		}

		waitForExpectations(timeout: 2.0) { error in
			XCTAssertNil(error, "Save did not occur")
		}
	}
	
	func testGetCampSiteWithMatchingSiteNumber() {
		_ = campSiteService.addCampSite(
			1,
			electricity: true,
			water: true)

		let campSite = campSiteService.getCampSite(1)
		XCTAssertNotNil(campSite, "A campsite should be returned")
	}

	func testGetCampSiteNoMatchingSiteNumber() {
		_ = campSiteService.addCampSite(
			1,
			electricity: true,
			water: true)

		let campSite = campSiteService.getCampSite(2)
		XCTAssertNil(campSite, "No campsite should be returned")
	}
	
	override func tearDown() {
		super.tearDown()

		campSiteService = nil
		coreDataStack = nil
	}
}
