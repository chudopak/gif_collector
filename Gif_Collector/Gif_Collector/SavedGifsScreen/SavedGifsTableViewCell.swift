//
//  SavedGifsTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/27/21.
//

import CoreData
import UIKit
import Gifu

class SavedGifTableViewCell: UITableViewCell {
	
	var gifData: Data!
	
	var gifSize: CGSize!
	private var _cellHeight: CGFloat = -1
	
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
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	public func configureCell() {
		_cellHeight = gifSize.height + 2 * gifVerticalOffset
		
		contentView.addSubview(gifView)
		gifView.addSubview(gifImageView)
		
		gifImageView.bounds.size = gifSize
		gifView.frame = CGRect(x: UIScreen.main.bounds.width * 0.5 - gifSize.width * 0.5,
							   y: gifVerticalOffset,
							   width: gifSize.width,
							   height: gifSize.height)
		
		gifImageView.frame = CGRect(x: 0,
									y: 0,
									width: gifView.bounds.size.width,
									height: gifView.bounds.size.height)
		gifImageView.animate(withGIFData: gifData)
	}
	
	
	static let identifier = "GifCell"
}
