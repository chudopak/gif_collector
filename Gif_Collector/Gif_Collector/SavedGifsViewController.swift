//
//  SavedGifsViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/24/21.
//

import UIKit
import CoreData

class SavedGifTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
	
	static let identifier = "GifCell"
}


extension SavedGifsViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return (sectionInfo.numberOfObjects)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SavedGifTableViewCell.identifier, for: indexPath) as! SavedGifTableViewCell
		let gif = fetchedResultsController.object(at: indexPath)
		cell.textLabel?.text = "boba \(gif.gifPixelWidth) \(gif.gifPixelHeight)"
		
		return (cell)
	}
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		print(indexPath.row)
//	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			let gifObj = fetchedResultsController.object(at: indexPath)
			managedObjectContext.delete(gifObj)
			do {
				try managedObjectContext.save()
			} catch {
				fatalError("fatal error delete obj Saved Gifs VC \(error)")
			}
		}
	}
}

extension SavedGifsViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("** Controller Will Change Content")
		tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (object)")
			tableView.insertRows(at: [newIndexPath!], with: .fade)

		case .delete:
			print("*** NSFetchedResyltsCHengeDelete (object)")
			tableView.deleteRows(at: [indexPath!], with: .fade)

		case .update:
			print("*** NSFetchedResyltsChengeUpdate (object)")
			if let cell = tableView.cellForRow(at: indexPath!) as? SavedGifTableViewCell {
				let gif = controller.object(at: indexPath!) as! Gif
				cell.textLabel?.text = "boba \(gif.gifPixelWidth) \(gif.gifPixelHeight)"
			}

		case .move:
			print("*** NSFetchedresultsChangeMove")
			tableView.deleteRows(at: [indexPath!], with: .fade)
			tableView.insertRows(at: [newIndexPath!], with: .fade)

		@unknown default:
			fatalError("Unhandled switch case of NSFetchedResyltsChangeType")
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (section)")
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)

		case .delete:
			print("*** NSFetchedResultsChangeDelete (section)")
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)

		case .update:
			print("*** NSFetchedResultsChangeUpdate (section)")
		case .move:
			print("*** NSFetchedResultsChangeMove (section)")
		@unknown default:
			fatalError("Unhandled switch case of NSFetchedResultsChangeType")
		}
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("*** controllerDidChangeContent")
		tableView.endUpdates()
	}
}

class SavedGifsViewController: UIViewController {
	
	lazy var fetchedResultsController: NSFetchedResultsController<Gif> = {
		let fetchRequest = NSFetchRequest<Gif>()
		
		let entity = Gif.entity()
		fetchRequest.entity = entity
		
		let sort1 = NSSortDescriptor(key: "date",
									 ascending: true)
		fetchRequest.sortDescriptors = [sort1]
		
		fetchRequest.fetchBatchSize = 20
		let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																managedObjectContext: self.managedObjectContext,
																sectionNameKeyPath: nil,
																cacheName: "Gif")
		fetchResultsController.delegate = self
		return (fetchResultsController)
	} ()
	
	var managedObjectContext: NSManagedObjectContext!
	
	let tableView = UITableView()
	
	init(managedObj: NSManagedObjectContext) {
		managedObjectContext = managedObj
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	deinit {
		fetchedResultsController.delegate = nil
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		_performFetch()
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(SavedGifTableViewCell.self, forCellReuseIdentifier: SavedGifTableViewCell.identifier)
		view.addSubview(tableView)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
	}
	
	private func _performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("Fetch error SavedGifsViewController \(error)")
		}
	}
}
