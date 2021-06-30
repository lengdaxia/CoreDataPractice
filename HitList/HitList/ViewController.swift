//
//  ViewController.swift
//  HitList
//
//  Created by leng on 2021/06/30.
//

import UIKit
import CoreData

class ViewController: UIViewController {

	
	
	@IBOutlet weak var tableView: UITableView!
	
//	var names:[String] = []
	var people:[NSManagedObject] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "The List"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		// Do any additional setup after loading the view.
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return  }
		
		let managedContext = appDelegate.persistentContainer.viewContext
		
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
		
		do {
			people = try managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			
			print("fetch failed: \(error),\(error.userInfo)")
		}
	}
	
	@IBAction func addName(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New", message: "add new name", preferredStyle: .alert)
		
		let alertAction = UIAlertAction(title: "添加", style: .destructive) { [unowned self] action in
			guard let textFiled = alert.textFields?.first,
				  let nameToSave = textFiled.text else{
				return
			}
			
			self.save(name: nameToSave)
			self.tableView.reloadData()
		}
		
		let cancelAction = UIAlertAction(title: "取消", style: .cancel)
		
		alert.addTextField()
		alert.addAction(alertAction)
		alert.addAction(cancelAction)
		
		present(alert, animated: true)
	}
	
	func save(name: String) {
		
		guard  let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		
		let managedContext = appdelegate.persistentContainer.viewContext
		
		let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
		
		let person = NSManagedObject(entity: entity, insertInto: managedContext)
		person.setValue(name, forKey: "name")
		
		do {
			
//			core data add
			try managedContext.save()
			
//
			people.append(person)
			
		} catch let error as NSError {
			print("保存失败 ：\(error),\(error.userInfo)")
		}
		
	}
}

extension ViewController: UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.people.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = people[indexPath.row].value(forKeyPath: "name") as? String
		
		return cell
	}
	
}

