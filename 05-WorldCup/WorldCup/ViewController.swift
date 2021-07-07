
import UIKit
import CoreData

class ViewController: UIViewController {
	
	var dataSource: UITableViewDiffableDataSource<String, NSManagedObjectID>?
	
  // MARK: - Properties
  private let teamCellIdentifier = "teamCellReuseIdentifier"
  lazy var  coreDataStack = CoreDataStack(modelName: "WorldCup")
	lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
		let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
		
//		必须传入排序的描述符
		let zoneSort = NSSortDescriptor(
			key: #keyPath(Team.qualifyingZone),
			ascending: true)
		let scoreSort = NSSortDescriptor(
			key: #keyPath(Team.wins),
			ascending: false)
		let nameSort = NSSortDescriptor(
			key: #keyPath(Team.teamName),
			ascending: true)

		let sort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
		
		fetchRequest.sortDescriptors = [zoneSort,scoreSort, nameSort]
		
		let fetchResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: coreDataStack.managedContext,
			sectionNameKeyPath: #keyPath(Team.qualifyingZone),
			cacheName: "worldCup")
		
		fetchResultsController.delegate = self
		return fetchResultsController
	}()

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    importJSONSeedDataIfNeeded()
		
		dataSource = setupDataSource()
		
		
  }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.performWithoutAnimation {
			
			do {
				try fetchedResultsController.performFetch()
			} catch let error as NSError {
				print("Fetching error: \(error), \(error.userInfo)")
			}
		}
	}
	
	override func motionEnded(
		_ motion: UIEvent.EventSubtype,
		with event: UIEvent?) {
		if motion == .motionShake {
			addButton.isEnabled = true
		}
	}
	
}

// MARK: - Internal
extension ViewController {
  func configure(cell: UITableViewCell, for team: Team) {
		
    guard let cell = cell as? TeamCell else {
      return
    }
		
    
		cell.teamLabel.text = team.teamName
		cell.scoreLabel.text = "Wins: \(team.wins)"
		
		
		if let imageName = team.imageName{
			cell.flagImageView.image = UIImage(named: imageName)
		}else{
			cell.flagImageView.image = nil
		}
  }
	
	func setupDataSource()
		-> UITableViewDiffableDataSource<String, NSManagedObjectID> {
			UITableViewDiffableDataSource(
			tableView: tableView
			) { [unowned self] (tableView, indexPath, managedObjectID)
				-> UITableViewCell? in

				let cell = tableView.dequeueReusableCell(
					withIdentifier: self.teamCellIdentifier,
					for: indexPath)

				if let team =
						try? coreDataStack.managedContext.existingObject(
							with: managedObjectID) as? Team {
					self.configure(cell: cell, for: team)
				}
				return cell
			}
	}
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
		fetchedResultsController.sections?.count ?? 0
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		
		return sectionInfo.numberOfObjects
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
		
//    configure(cell: cell, for: indexPath)
    return cell
  }
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let sectionInfo = fetchedResultsController.sections?[section]
		return sectionInfo?.name
	}
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView,
								 viewForHeaderInSection section: Int) -> UIView? {

		let sectionInfo = fetchedResultsController.sections?[section]

		let titleLabel = UILabel()
		titleLabel.backgroundColor = .white
		titleLabel.text = sectionInfo?.name

		return titleLabel
	}

	func tableView(_ tableView: UITableView,
								 heightForHeaderInSection section: Int)
		-> CGFloat {
		20
	}
	
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let team = fetchedResultsController.object(at: indexPath)
		team.wins += 1
		if var snapshot = dataSource?.snapshot(){
			snapshot.reloadItems([team.objectID])
			dataSource?.apply(snapshot, animatingDifferences: false)
		}
		
		coreDataStack.saveContext()
		tableView.reloadData()
  }
}


extension ViewController {
	func importJSONSeedDataIfNeeded() {
// MARK: - Helper methods
    let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
    let count = try? coreDataStack.managedContext.count(for: fetchRequest)

    guard let teamCount = count,
      teamCount == 0 else {
        return
    }

    importJSONSeedData()
  }

  // swiftlint:disable force_unwrapping force_cast force_try
  func importJSONSeedData() {
    let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonURL)

    do {
      let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [[String: Any]]

      for jsonDictionary in jsonArray {
        let teamName = jsonDictionary["teamName"] as! String
        let zone = jsonDictionary["qualifyingZone"] as! String
        let imageName = jsonDictionary["imageName"] as! String
        let wins = jsonDictionary["wins"] as! NSNumber

        let team = Team(context: coreDataStack.managedContext)
        team.teamName = teamName
        team.imageName = imageName
        team.qualifyingZone = zone
        team.wins = wins.int32Value
      }

      coreDataStack.saveContext()
      print("Imported \(jsonArray.count) teams")
    } catch let error as NSError {
      print("Error importing teams: \(error)")
    }
  }
  // swiftlint:enable force_unwrapping force_cast force_try
}


extension ViewController: NSFetchedResultsControllerDelegate{
	
	func controller( _ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
		
		let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
			dataSource?.apply(snapshot)
	}
	
//	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//		tableView.beginUpdates()
//	}
//
//	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//
//		switch type {
//		case .insert:
//			tableView.insertRows(at: [newIndexPath!], with: .automatic)
//		case .delete:
//			tableView.deleteRows(at: [indexPath!], with: .automatic)
//		case .update:
//			let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
//			configure(cell: cell, for: indexPath!)
//		case .move:
//			tableView.deleteRows(at: [indexPath!], with: .automatic)
//			tableView.insertRows(at: [newIndexPath!], with: .automatic)
//		@unknown default:
//			print("Unexpected NSFetchedResultsChangeType")
//		}
//	}
//
//	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//		tableView.endUpdates()
//	}
//
//
//	func controller(_ controller:
//		NSFetchedResultsController<NSFetchRequestResult>,
//		didChange sectionInfo: NSFetchedResultsSectionInfo,
//		atSectionIndex sectionIndex: Int,
//		for type: NSFetchedResultsChangeType) {
//
//		let indexSet = IndexSet(integer: sectionIndex)
//
//		switch type {
//		case .insert:
//			tableView.insertSections(indexSet, with: .automatic)
//		case .delete:
//			tableView.deleteSections(indexSet, with: .automatic)
//		default: break
//		}
//	}

}


// MARK: - IBActions
extension ViewController {
	@IBAction func addTeam(_ sender: Any) {
		let alertController = UIAlertController(
			title: "Secret Team",
			message: "Add a new team",
			preferredStyle: .alert)

		alertController.addTextField { textField in
			textField.placeholder = "Team Name"
		}

		alertController.addTextField { textField in
			textField.placeholder = "Qualifying Zone"
		}

		let saveAction = UIAlertAction(
			title: "Save",
			style: .default
		) { [unowned self] _ in

			guard
				let nameTextField = alertController.textFields?.first,
				let zoneTextField = alertController.textFields?.last
				else {
					return
			}
			
			
			let team = Team(
				context: self.coreDataStack.managedContext)

			team.teamName = nameTextField.text
			team.qualifyingZone = zoneTextField.text
			team.imageName = "wenderland-flag"
			self.coreDataStack.saveContext()
		}

		alertController.addAction(saveAction)
		alertController.addAction(UIAlertAction(title: "Cancel",
																						style: .cancel))

		present(alertController, animated: true)
	}
}
