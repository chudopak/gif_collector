//
//  SavedGifsViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/24/21.
//

import UIKit
import CoreData

extension SavedGifsViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		if (sectionInfo.numberOfObjects == 0) {
			if (view.subviews.count == 1) {
				view.addSubview(_showRandomGifVCButton)
				_showRandomGifVCButton.center = view.center
			}
		} else {
			if (view.subviews.count > 1) {
				_showRandomGifVCButton.removeFromSuperview()
			}
		}
		return (sectionInfo.numberOfObjects)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SavedGifTableViewCell.identifier, for: indexPath) as! SavedGifTableViewCell

		let gif = fetchedResultsController.object(at: indexPath)
		let gifSize = GifSize(width: CGFloat(gif.gifPixelWidth), height: CGFloat(gif.gifPixelHeight))
		cell.gifSize = _countGifViewSize(gif: gifSize)
		cell.gifData = gif.gifData
		cell.configureCell()
		return (cell)
	}

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
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let gif = fetchedResultsController.object(at: indexPath)
		let gifPixelSize = GifSize(width: CGFloat(gif.gifPixelWidth), height: CGFloat(gif.gifPixelHeight))
		let gifPointSize = _countGifViewSize(gif: gifPixelSize)

		return (gifPointSize.height + 2 * gifVerticalOffset)
	}
	
	private func _countGifViewSize(gif: GifSize) -> CGSize {
		let ratio = gif.height / gif.width
		var gifViewSize = CGSize(width: -1, height: -1)

		if (gif.width == -1 || gif.height == -1) {
			gifViewSize = CGSize(width: _availableCellWidth,
										 height: _availableCellHeight)
			return (gifViewSize)
		}
		
		if (_availableCellWidth * ratio <= _availableCellHeight) {
			gifViewSize.width = _availableCellWidth
			gifViewSize.height = gifViewSize.width * ratio
		} else if (_availableCellHeight / ratio <= _availableCellWidth) {
			gifViewSize.height = _availableCellHeight
			gifViewSize.width = gifViewSize.height / ratio
		} else {
			gifViewSize = CGSize(width: _availableCellWidth,
										 height: _availableCellHeight)
		}
		return (gifViewSize)
	}
}

extension SavedGifsViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		print("** Controller Will Change Content")
		_tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (object)")
			_tableView.insertRows(at: [newIndexPath!], with: .fade)

		case .delete:
			print("*** NSFetchedResyltsCHengeDelete (object)")
			_tableView.deleteRows(at: [indexPath!], with: .fade)

		case .update:
			print("*** NSFetchedResyltsChengeUpdate (object)")

		case .move:
			print("*** NSFetchedresultsChangeMove")
			_tableView.deleteRows(at: [indexPath!], with: .fade)
			_tableView.insertRows(at: [newIndexPath!], with: .fade)

		@unknown default:
			fatalError("Unhandled switch case of NSFetchedResyltsChangeType")
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			print("*** NSFetchedResultsChangeInsert (section)")
			_tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)

		case .delete:
			print("*** NSFetchedResultsChangeDelete (section)")
			_tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)

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
		_tableView.endUpdates()
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
	
	private let _tableView = UITableView()
	
	private lazy var _noItemsLabel: UILabel = {
		let label = UILabel()
		
		let boldText = "Explore "
		let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24)]
		let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

		let normalText = "new gifs"
		let normalString = NSMutableAttributedString(string:normalText)

		attributedString.append(normalString)
		
		label.attributedText = attributedString
		label.textColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColor)
			default:
				return (lightThemeTintColor)
			}
		}
		label.translatesAutoresizingMaskIntoConstraints = false
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.numberOfLines = 0
		label.textAlignment = .center
		return (label)
	}()
	
	private lazy var _showRandomGifVCButton: UIButton = {
		let button = UIButton()
		button.bounds.size = CGSize(width: UIScreen.main.bounds.width - 2 * gifHorizontalOffset,
									height: UIScreen.main.bounds.height * 0.3)
		button.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addSubview(_noItemsLabel)
		button.addTarget(self, action: #selector(_showRandomGifVC), for: .touchUpInside)
		return (button)
	}()
	
	private let _availableCellWidth: CGFloat = UIScreen.main.bounds.width - 2 * gifHorizontalOffset
	private let _availableCellHeight: CGFloat = UIScreen.main.bounds.height * 0.7 - 2 * gifHorizontalOffset
	
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
		_noItemsLabel.frame = CGRect(x: 0,
									 y: 0,
									 width: _showRandomGifVCButton.bounds.size.width,
									 height: _showRandomGifVCButton.bounds.size.height)
		_performFetch()
		_tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		_tableView.delegate = self
		_tableView.dataSource = self
		_tableView.separatorColor = .none
		_tableView.separatorStyle = .none
		_tableView.register(SavedGifTableViewCell.self, forCellReuseIdentifier: SavedGifTableViewCell.identifier)
		view.addSubview(_tableView)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		_tableView.frame = view.bounds
	}

	private func _performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("Fetch error SavedGifsViewController \(error)")
		}
	}

	@objc private func _showRandomGifVC() {
		tabBarController?.selectedIndex = 1
	}
}
