
import UIKit
import CoreData

class ViewController: UIViewController {
	lazy var coreDataStack = CoreDataStack(modelName: "DogWalk")
	
  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()

	var currentDog: Dog?
//  var walks: [Date] = []

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
		let dogName = "Fido"
		let dogFetch:NSFetchRequest<Dog> = Dog.fetchRequest()
		dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
		
		do {
			let results = try coreDataStack.managedContext.fetch(dogFetch)
			if results.isEmpty {
				currentDog = Dog(context: coreDataStack.managedContext)
				currentDog?.name = dogName
				
				coreDataStack.saveContext()
			}else{
				
				currentDog = results.first
			}
		} catch let error as NSError {
			print("fetch Error: \(error),\(error.userInfo)")
		}
		
		

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func add(_ sender: UIBarButtonItem) {
			
		let walk = Walk(context: coreDataStack.managedContext)
		walk.date = Date()
		
//		if let dog = currentDog,
//			 let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet{
//
//			walks.add(walk)
//			dog.walks = walks
//		}
		currentDog?.addToWalks(walk)
		
		coreDataStack.saveContext()

    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		 currentDog?.walks?.count ?? 0
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
		
//    let date = currentDog?.walks?[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "Cell", for: indexPath)
		guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
				let walkDate = walk.date
				else { return cell }
		
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    "List of Walks"
  }
}

extension ViewController: UITableViewDelegate{
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk,
					editingStyle == .delete
					else { return }
		
//		coreDataStack.managedContext.delete(walkToRemove)
		currentDog?.removeFromWalks(at: indexPath.row)
		
		coreDataStack.saveContext()
		
		tableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
}
