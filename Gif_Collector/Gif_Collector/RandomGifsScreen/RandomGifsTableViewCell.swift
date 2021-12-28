//
//  GifTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Gifu


class GifTableViewCell: UITableViewCell {
	
	private lazy var _leftView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
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
	
	private lazy var _rightView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
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

	private lazy var _leftGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
	private lazy var _rightGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.layer.cornerRadius = 3.0
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

        // Configure the view for the selected state
    }
	
	public func configureGifs(gifs: RowGifsData?, topBarOffset: CGFloat) {

		_setViewsSize(leftGifSize: gifs?.leftGif.pointSize ?? GifSize(width: -1, height: -1),
								   rightGifSize: gifs?.rightGif.pointSize ?? GifSize(width: -1, height: -1))
		_setViewsPosition(topBarOffset: topBarOffset)
		
		_leftView.addSubview(_leftGifImageView)
		_rightView.addSubview(_rightGifImageView)

		contentView.addSubview(_rightView)
		contentView.addSubview(_leftView)
		if let gifs = gifs {
			_leftGifImageView.animate(withGIFData: gifs.leftGif.gif)
			_rightGifImageView.animate(withGIFData: gifs.rightGif.gif)
		}
		else {
			_resizeViewsForLoadingIndicatorGif()

			_leftGifImageView.animate(withGIFNamed: "loadingPNGCircles")
			_rightGifImageView.animate(withGIFNamed: "loadingPNGCircles")
		}
	}
	
	private func _resizeViewsForLoadingIndicatorGif() {
		_leftGifImageView.bounds.size.width = _leftGifImageView.bounds.size.width / 2
		_leftGifImageView.bounds.size.height = _leftGifImageView.bounds.size.height / 2
		_leftGifImageView.frame.origin = CGPoint(
			x: _leftView.bounds.size.width / 2 - _leftGifImageView.bounds.size.width / 2,
			y: _leftView.bounds.size.height / 2 - _leftGifImageView.bounds.size.height / 2)

		_rightGifImageView.bounds.size.width = _rightGifImageView.bounds.size.width / 2
		_rightGifImageView.bounds.size.height = _rightGifImageView.bounds.size.height / 2
		_rightGifImageView.frame.origin = CGPoint(
			x: _rightView.bounds.size.width / 2 - _rightGifImageView.bounds.size.width / 2,
			y: _rightView.bounds.size.height / 2 - _rightGifImageView.bounds.size.height / 2)
	}
	
	private func _setViewsPosition(topBarOffset: CGFloat) {
		_leftView.frame.origin = CGPoint(
				x: gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - _leftView.bounds.size.height / 2 + topBarOffset / 2)
		_rightView.frame.origin = CGPoint(
				x: contentView.bounds.size.width - _rightView.bounds.size.width - gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - _rightView.bounds.size.height / 2 + topBarOffset / 2)
		_leftGifImageView.frame.origin = CGPoint(x: 0, y: 0)
		_rightGifImageView.frame.origin = CGPoint(x: 0, y: 0)
	}

	private func _setViewsSize(leftGifSize: GifSize, rightGifSize: GifSize) {
		if (leftGifSize.height != -1 && leftGifSize.width != -1 && rightGifSize.height != -1 && rightGifSize.width != -1) {
			_leftView.bounds.size.width = leftGifSize.width
			_leftView.bounds.size.height = leftGifSize.height
			_rightView.bounds.size.width = rightGifSize.width
			_rightView.bounds.size.height = rightGifSize.height
		}
		else if (leftGifSize.height != -1 && leftGifSize.width != -1) {
			_rightGifImageView.bounds.size.width = rightGifSize.width
			_rightGifImageView.bounds.size.height = rightGifSize.height
			_leftGifImageView.bounds.size.width = UIScreen.main.bounds.width - 3 * gifHorizontalOffset - rightGifSize.width
			_leftGifImageView.bounds.size.height = rightGifSize.height
			print("left 0")
		}
		else if (rightGifSize.height != -1 && rightGifSize.width != -1) {
			_leftView.bounds.size.width = leftGifSize.width
			_leftView.bounds.size.height = leftGifSize.height
			_rightGifImageView.bounds.size.width = UIScreen.main.bounds.width - 3 * gifHorizontalOffset - leftGifSize.width
			_rightGifImageView.bounds.size.height = leftGifSize.height
			print("right 0")
		}
		else {
			_leftView.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
			_leftView.bounds.size.height = _leftView.bounds.size.width
			_rightView.bounds.size.width = _leftView.bounds.size.width
			_rightView.bounds.size.height = _leftView.bounds.size.width
		}
		_leftGifImageView.bounds.size.width = _leftView.bounds.size.width
		_leftGifImageView.bounds.size.height = _leftView.bounds.size.height
		_rightGifImageView.bounds.size.width = _rightView.bounds.size.width
		_rightGifImageView.bounds.size.height = _rightView.bounds.size.height
	}

// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
