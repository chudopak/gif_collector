//
//  GifTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Gifu


class GifTableViewCell: UITableViewCell {
	
	let leftView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 5
		v.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		v.clipsToBounds = true
		return (v)
	}()
	
	let rightView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 5
		v.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		v.clipsToBounds = true
		return (v)
	}()

	let leftGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
	let rightGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.layer.cornerRadius = 3.0
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
//	let leftLoadingIndicator = UIActivityIndicatorView(style: .large)
//	let rightLoadingIndicator = UIActivityIndicatorView(style: .large)
	
	
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
//		if (traitCollection.userInterfaceStyle == .light) {
//			leftLoadingIndicator.color = UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1)
//			rightLoadingIndicator.color = UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1)
//		} else {
//			rightLoadingIndicator.color = UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1)
//			leftLoadingIndicator.color = UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1)
//		}
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
	
	public func configureGifs(gifs: RowGifsData?, topBarOffset: CGFloat) {

		_setViewsSize(leftGifSize: gifs?.leftGif.pointSize ?? GifSize(width: -1, height: -1),
								   rightGifSize: gifs?.rightGif.pointSize ?? GifSize(width: -1, height: -1))
		_setViewsPosition(topBarOffset: topBarOffset)
		
		leftView.addSubview(leftGifImageView)
		rightView.addSubview(rightGifImageView)

		contentView.addSubview(rightView)
		contentView.addSubview(leftView)
		if let gifs = gifs {
			leftGifImageView.animate(withGIFData: gifs.leftGif.gif)
			rightGifImageView.animate(withGIFData: gifs.rightGif.gif)
		}
		else {
			_resizeViewsForLoadingIndicatorGif()

			leftGifImageView.animate(withGIFNamed: "loadingPNGCircles")
			rightGifImageView.animate(withGIFNamed: "loadingPNGCircles")
		}
	}
	
	private func _resizeViewsForLoadingIndicatorGif() {
		leftGifImageView.bounds.size.width = leftGifImageView.bounds.size.width / 2
		leftGifImageView.bounds.size.height = leftGifImageView.bounds.size.height / 2
		leftGifImageView.frame.origin = CGPoint(
			x: leftView.bounds.size.width / 2 - leftGifImageView.bounds.size.width / 2,
			y: leftView.bounds.size.height / 2 - leftGifImageView.bounds.size.height / 2)

		rightGifImageView.bounds.size.width = rightGifImageView.bounds.size.width / 2
		rightGifImageView.bounds.size.height = rightGifImageView.bounds.size.height / 2
		rightGifImageView.frame.origin = CGPoint(
			x: rightView.bounds.size.width / 2 - rightGifImageView.bounds.size.width / 2,
			y: rightView.bounds.size.height / 2 - rightGifImageView.bounds.size.height / 2)
	}
	
	private func _setViewsPosition(topBarOffset: CGFloat) {
		leftView.frame.origin = CGPoint(
				x: gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - leftView.bounds.size.height / 2 + topBarOffset / 2)
		rightView.frame.origin = CGPoint(
				x: contentView.bounds.size.width - rightView.bounds.size.width - gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - rightView.bounds.size.height / 2 + topBarOffset / 2)
		leftGifImageView.frame.origin = CGPoint(x: 0, y: 0)
		rightGifImageView.frame.origin = CGPoint(x: 0, y: 0)
	}

	private func _setViewsSize(leftGifSize: GifSize, rightGifSize: GifSize) {
		if (leftGifSize.height != -1 && leftGifSize.width != -1 && rightGifSize.height != -1 && rightGifSize.width != -1) {
			leftView.bounds.size.width = leftGifSize.width
			leftView.bounds.size.height = leftGifSize.height
			rightView.bounds.size.width = rightGifSize.width
			rightView.bounds.size.height = rightGifSize.height
		}
		else if (leftGifSize.height != -1 && leftGifSize.width != -1) {
			rightGifImageView.bounds.size.width = rightGifSize.width
			rightGifImageView.bounds.size.height = rightGifSize.height
			leftGifImageView.bounds.size.width = UIScreen.main.bounds.width - 3 * gifHorizontalOffset - rightGifSize.width
			leftGifImageView.bounds.size.height = rightGifSize.height
			print("left 0")
		}
		else if (rightGifSize.height != -1 && rightGifSize.width != -1) {
			leftView.bounds.size.width = leftGifSize.width
			leftView.bounds.size.height = leftGifSize.height
			rightGifImageView.bounds.size.width = UIScreen.main.bounds.width - 3 * gifHorizontalOffset - leftGifSize.width
			rightGifImageView.bounds.size.height = leftGifSize.height
			print("right 0")
		}
		else {
			leftView.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
			leftView.bounds.size.height = leftView.bounds.size.width
			rightView.bounds.size.width = leftView.bounds.size.width
			rightView.bounds.size.height = leftView.bounds.size.width
		}
		leftGifImageView.bounds.size.width = leftView.bounds.size.width
		leftGifImageView.bounds.size.height = leftView.bounds.size.height
		rightGifImageView.bounds.size.width = rightView.bounds.size.width
		rightGifImageView.bounds.size.height = rightView.bounds.size.height
	}

// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
