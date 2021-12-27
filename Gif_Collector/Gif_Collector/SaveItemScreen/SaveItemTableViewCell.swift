//
//  SaveItemTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/27/21.
//

import Foundation
import UIKit
import Gifu

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
				return (darkThemeTintColor)
			default:
				return (lightThemeTintColor)
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
		
		gifView.frame = CGRect(x: gifHorizontalOffset,
							   y: _cellHeight * 0.5 - gifSize.height * 0.5,
							   width: gifSize.width,
							   height: gifSize.height)
		gifImageView.frame = CGRect(x: 0,
									y: 0,
									width: gifView.bounds.size.width,
									height: gifView.bounds.size.height)
		
		saveGifButton.frame = CGRect(x:  UIScreen.main.bounds.width - buttonSidesize - gifHorizontalOffset,
									 y: _cellHeight * 0.5 - buttonSidesize * 0.5,
									 width: buttonSidesize,
									 height: buttonSidesize)
		
		gifImageView.animate(withGIFData: gifToPresent.gif)
	}
	

	
	//MARK: - identifier
	static let identifier = "SaveItem"
}
