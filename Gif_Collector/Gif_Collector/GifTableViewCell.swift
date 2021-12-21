//
//  GifTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Gifu


class GifTableViewCell: UITableViewCell {
	
	let gifSize: GifSize = GifSize(width: -1, height: -1)
	
	let leftView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 10
		v.clipsToBounds = true
		return (v)
	}()
	
	let rightView: UIView = {
		let v = UIView(frame: CGRect(x: 0,
									 y: 0,
									 width: UIScreen.main.bounds.width / 2 - 15,
									 height: UIScreen.main.bounds.width / 2 - 15))
		v.translatesAutoresizingMaskIntoConstraints = false
		v.layer.cornerRadius = 10
		v.clipsToBounds = true
		return (v)
	}()

	let leftGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFit
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
	let rightGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFit
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.layer.cornerRadius = 3.0
		image.translatesAutoresizingMaskIntoConstraints = false
		return (image)
	} ()
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	public func configureGifs(leftGif: GifData?, rightGif: GifData?, semaphoreThreads: DispatchSemaphore ) {
		leftView.addSubview(leftGifImageView)
		rightView.addSubview(rightGifImageView)
		contentView.addSubview(rightView)
		contentView.addSubview(leftView)
		_setAndActivateConstraints(leftGifSize: leftGif?.pixelSize ?? GifSize(width: -1, height: -1),
								   rightGifSize: rightGif?.pixelSize ?? GifSize(width: -1, height: -1))

		semaphoreThreads.wait()
		if let leftGif = leftGif {
			leftGifImageView.animate(withGIFData: leftGif.gif)
		} else {
			leftGifImageView.animate(withGIFNamed: "giphy")
		}
		semaphoreThreads.signal()
		
		semaphoreThreads.wait()
		if let rightGif = rightGif {
			rightGifImageView.animate(withGIFData: rightGif.gif)
		} else {
			rightGifImageView.animate(withGIFNamed: "giphy")
		}
		semaphoreThreads.signal()
	}
	
	private func _setAndActivateConstraints(leftGifSize: GifSize, rightGifSize: GifSize) {
		
//		var leftGifSizeConvertedInPoints = GifSize(width: -1, height: -1)
//		var rightGifSizeConvertedInPoints = GifSize(width: -1, height: -1)
		
		
		
		NSLayoutConstraint.activate([
			leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: gifHorizontalOffset),
			leftView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: gifVerticalOffset),
			leftView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			leftView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			
			rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gifHorizontalOffset),
			rightView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: gifVerticalOffset),
			rightView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			rightView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			
			rightGifImageView.rightAnchor.constraint(equalTo: rightView.rightAnchor, constant: 0),
			rightGifImageView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: 0),
			rightGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			rightGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			
			leftGifImageView.leftAnchor.constraint(equalTo: leftView.leftAnchor, constant: 0),
			leftGifImageView.topAnchor.constraint(equalTo: leftView.topAnchor, constant: 0),
			leftGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			leftGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15)
		])
	}
	
	func getCellHeight(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		var leftGifRatio: CGFloat = -1
		var rightGifRatio: CGFloat = -1
		let leftViewWidht = _getLeftViewWidth(leftGifSize: leftGifSize, rightGifSize: rightGifSize)
		let rightViewWidht = _getRightViewWidth(leftGifSize: leftGifSize, rightGifSize: rightGifSize)
		
		if (leftViewWidht != -1) {
			leftGifRatio = CGFloat(leftGifSize.height / leftGifSize.width)
		}
		if (rightViewWidht != -1) {
			rightGifRatio = CGFloat(rightGifSize.height / rightGifSize.width)
		}
		
		if (leftGifRatio == -1 && rightGifRatio == -1){
			return (UIScreen.main.bounds.width / 2 + 5)
		}
		else if (leftGifRatio == -1) {
			return (rightViewWidht * rightGifRatio)
		}
		else if (rightGifRatio == -1) {
			return (leftViewWidht * leftGifRatio)
		}
		return (leftGifRatio < rightGifRatio ? rightViewWidht * rightGifRatio : leftViewWidht * leftGifRatio)
	}
	
	private func _getLeftViewWidth(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		if (leftGifSize.width == -1 || leftGifSize.height == -1) {
			return (-1)
		}
		let widthOfTwoGifs = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
		let viewWidth = widthOfTwoGifs / 2 * CGFloat(leftGifSize.width / rightGifSize.width)
		return (viewWidth)
	}
	
	private func _getRightViewWidth(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		if (rightGifSize.width == -1 || rightGifSize.height == -1) {
			return (-1)
		}
		let widthOfTwoGifs = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
		let viewWidth = widthOfTwoGifs / 2 * CGFloat(rightGifSize.width / leftGifSize.width)
		return (viewWidth)
	}


// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
