//
//  SaveItemViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/25/21.
//

import UIKit
import Gifu

protocol SaveItemViewControllerDelegate: AnyObject {
	func shouldSaveGifDelegate(isFirst: Bool, shouldSave: Bool)
}

class SaveItemTableViewCell: UITableViewCell {
	
	var gifToPresent: GifData!
	
	var isFirst: Bool!
	
	weak var delegate: SaveItemViewControllerDelegate!

	var gifSize: CGSize!
	private var _cellHeight: CGFloat = -1
	private var _shouldSaveGif = false
	private let buttonSidesize = (UIScreen.main.bounds.width - 3 * gifHorizontalOffset) * 0.1
	
	private let _saveButtonImageConfig = UIImage.SymbolConfiguration(
												pointSize: (UIScreen.main.bounds.width - 3 * gifHorizontalOffset) * 0.1,
												weight: .regular,
												scale: .medium)
	
	private lazy var saveButtonImageCircle = UIImage(systemName: "circle", withConfiguration: _saveButtonImageConfig)
	private lazy var saveButtonImageCircleFilled = UIImage(systemName: "circle.fill", withConfiguration: _saveButtonImageConfig)
	
	private let gifView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: 0,
									 height: 0))
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 5
		v.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		v.clipsToBounds = true
		return (v)
	}()

	private let gifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
	lazy var saveGifButton: UIButton = {
		let button = UIButton()
		button.bounds.size = CGSize(width: buttonSidesize,
									height: buttonSidesize)
		button.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		button.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
			}
		}
		button.setImage(UIImage(systemName: "circle", withConfiguration: _saveButtonImageConfig), for: .normal)
		button.addTarget(self, action: #selector(_saveButtonPressed), for: .touchUpInside)
		return (button)
	} ()
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
	}
	
	@objc private func _saveButtonPressed() {
		_shouldSaveGif = !_shouldSaveGif
		if (!_shouldSaveGif) {
			saveGifButton.setImage(saveButtonImageCircle, for: .normal)
		} else {
			saveGifButton.setImage(saveButtonImageCircleFilled, for: .normal)
		}
		delegate.shouldSaveGifDelegate(isFirst: isFirst, shouldSave: _shouldSaveGif)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	func configureCell() {
		_cellHeight = gifSize.height >= saveGifButton.bounds.size.height ? gifSize.height + 2 * gifVerticalOffset : saveGifButton.bounds.size.height + 2 * gifVerticalOffset
		
		contentView.addSubview(gifView)
		contentView.addSubview(saveGifButton)
		gifView.addSubview(gifImageView)
		
		gifImageView.bounds.size = gifSize
		gifView.frame = CGRect(x: gifHorizontalOffset,
							   y: _cellHeight / 2 - gifSize.height / 2,
							   width: gifSize.width,
							   height: gifSize.height)
		gifImageView.frame = CGRect(x: 0,
									y: 0,
									width: gifView.bounds.size.width,
									height: gifView.bounds.size.height)
		
		saveGifButton.frame = CGRect(x:  UIScreen.main.bounds.width - buttonSidesize - gifHorizontalOffset,
									 y: _cellHeight / 2 - buttonSidesize / 2,
									 width: buttonSidesize,
									 height: buttonSidesize)
		
		gifImageView.animate(withGIFData: gifToPresent.gif)
	}
	

	
	//MARK: - identifier
	static let identifier = "SaveItem"
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

	private let tableView = UITableView()
	
	var firstGif: GifData!
	var secondGif: GifData!
	
	var cellHeight: CGFloat = 0
	
	private var _shouldSaveFirst: Bool = false
	private var _shouldSaveSecond: Bool = false
	
	let availableCellWidth: CGFloat = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
	let availableCellHeight: CGFloat = UIScreen.main.bounds.height * 0.6 - 2 * gifHorizontalOffset
	
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
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
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
			gifViewSize = CGSize(width: availableCellWidth,
										 height: availableCellHeight)
			return (gifViewSize)
		}
		
		if (availableCellWidth * 0.8 * ratio <= availableCellHeight) {
			gifViewSize.width = availableCellWidth * 0.8
			gifViewSize.height = gifViewSize.width * ratio
		} else if (availableCellHeight / ratio <= availableCellWidth * 0.8) {
			gifViewSize.height = availableCellHeight
			gifViewSize.width = gifViewSize.height / ratio
		} else {
			gifViewSize = CGSize(width: availableCellWidth * 0.8,
										 height: availableCellHeight)
		}
		return (gifViewSize)
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func save() {
		let hudView = HudView.hud(inView: navigationController!.view, animated: true)
		hudView.text = "saved"
		DispatchQueue.global().async {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
				self.dismiss(animated: true, completion: nil)
				print("we here")
			}
		}
	}
	
	func shouldSaveGifDelegate(isFirst: Bool, shouldSave: Bool) {
		if (isFirst) {
			_shouldSaveFirst = shouldSave
		} else {
			_shouldSaveSecond = shouldSave
		}
		print(shouldSave)
	}
}
