//
//  SaveItemViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/25/21.
//

import UIKit
import Gifu
import CoreData

protocol SaveItemViewControllerDelegate: AnyObject {
	func shouldSaveGifDelegate(isFirst: Bool, shouldSave: Bool)
}

extension SaveItemViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (2)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SaveItemTableViewCell.identifier, for: indexPath) as! SaveItemTableViewCell
		
		cell.delegate = self
		switch indexPath.row {
		case 0:
			cell.gifToPresent = firstGif
			cell.isFirst = true
		default:
			cell.gifToPresent = secondGif
			cell.isFirst = false
		}
		cell.gifSize = _countGifViewSize(gif: cell.gifToPresent.pixelSize)
		cell.configureCell()
		return (cell)
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		var gif: CGSize
		switch indexPath.row {
		case 0:
			gif = _countGifViewSize(gif: firstGif.pixelSize)
		default:
			gif = _countGifViewSize(gif: secondGif.pixelSize)
		}
		return (gif.height + 2 * gifVerticalOffset)
	}
}

class SaveItemViewController: UIViewController, SaveItemViewControllerDelegate {

	var managedObjectContext: NSManagedObjectContext!
	
	private let tableView = UITableView()
	
	var firstGif: GifData!
	var secondGif: GifData!
	
	var cellHeight: CGFloat = 0
	
	private var _shouldSaveFirst: Bool = false
	private var _shouldSaveSecond: Bool = false
	
	private let _availableCellWidth: CGFloat = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
	private let _availableCellHeight: CGFloat = UIScreen.main.bounds.height * 0.6 - 2 * gifHorizontalOffset
	
    override func viewDidLoad() {
        super.viewDidLoad()
		_setTableView()
		_setNavigationBar()
	}
	
	private func _setTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorColor = .none
		tableView.separatorStyle = .none
		tableView.register(SaveItemTableViewCell.self, forCellReuseIdentifier: SaveItemTableViewCell.identifier)
		view.addSubview(tableView)
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
	}
	
	private func _setNavigationBar() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
		navigationController?.navigationBar.barTintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
				case .dark:
					return (UIColor(red: 0.19, green: 0.195, blue: 0.199, alpha: 1))
				default:
					return (UIColor(red: 0.945, green: 0.894, blue: 0.734, alpha: 1))
			}
		}
		navigationController?.navigationBar.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColor)
			default:
				return (lightThemeTintColor)
			}
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
	}
	
	private func _countGifViewSize(gif: GifSize) -> CGSize {
		let ratio = gif.height / gif.width
		var gifViewSize = CGSize(width: -1, height: -1)

		if (gif.width == -1 || gif.height == -1) {
			gifViewSize = CGSize(width: _availableCellWidth,
										 height: _availableCellHeight)
			return (gifViewSize)
		}
		
		if (_availableCellWidth * 0.8 * ratio <= _availableCellHeight) {
			gifViewSize.width = _availableCellWidth * 0.8
			gifViewSize.height = gifViewSize.width * ratio
		} else if (_availableCellHeight / ratio <= _availableCellWidth * 0.8) {
			gifViewSize.height = _availableCellHeight
			gifViewSize.width = gifViewSize.height / ratio
		} else {
			gifViewSize = CGSize(width: _availableCellWidth * 0.8,
										 height: _availableCellHeight)
		}
		return (gifViewSize)
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func save() {
		let hudView = HudView.hud(inView: navigationController!.view, animated: true)
		if (_shouldSaveSecond || _shouldSaveFirst) {
			hudView.isAnythingToSave = true
			hudView.text = "saved"
		} else {
			hudView.isAnythingToSave = false
			hudView.text = "no saves"
		}
		if (_shouldSaveFirst) {
			let coreDataFirstGif = Gif(context: managedObjectContext)
			
			coreDataFirstGif.gifData = firstGif.gif
			coreDataFirstGif.gifPixelWidth = Int32(firstGif.pixelSize.width)
			coreDataFirstGif.gifPixelHeight = Int32(firstGif.pixelSize.height)
			coreDataFirstGif.date = Date()
			
			do {
				try managedObjectContext.save()
			} catch {
				fatalError("Could load data store \(error)")
			}
		}
		
		if (_shouldSaveSecond) {
			let coreDataSecondGif = Gif(context: managedObjectContext)
			
			coreDataSecondGif.gifData = secondGif.gif
			coreDataSecondGif.gifPixelWidth = Int32(secondGif.pixelSize.width)
			coreDataSecondGif.gifPixelHeight = Int32(secondGif.pixelSize.height)
			coreDataSecondGif.date = Date()
			
			do {
				try managedObjectContext.save()
			} catch {
				fatalError("Could load data store \(error)")
			}
		}
		
		
		DispatchQueue.global().async {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	func shouldSaveGifDelegate(isFirst: Bool, shouldSave: Bool) {
		if (isFirst) {
			_shouldSaveFirst = shouldSave
		} else {
			_shouldSaveSecond = shouldSave
		}
	}
}
