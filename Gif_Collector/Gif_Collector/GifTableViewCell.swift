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
	
	public func configureGifs(gifs: RowGifsData?, semaphoreThreads: DispatchSemaphore ) {
		leftView.addSubview(leftGifImageView)
		rightView.addSubview(rightGifImageView)
		contentView.addSubview(rightView)
		contentView.addSubview(leftView)
		_setAndActivateConstraints(leftGifSize: gifs?.leftGif.pointSize ?? GifSize(width: -1, height: -1),
								   rightGifSize: gifs?.rightGif.pointSize ?? GifSize(width: -1, height: -1))

		if let gifs = gifs {
			semaphoreThreads.wait()
			leftGifImageView.animate(withGIFData: gifs.leftGif.gif)
			semaphoreThreads.signal()
			semaphoreThreads.wait()
			rightGifImageView.animate(withGIFData: gifs.rightGif.gif)
			semaphoreThreads.signal()
		} else {
			semaphoreThreads.wait()
			leftGifImageView.animate(withGIFNamed: "giphy")
			semaphoreThreads.signal()
			semaphoreThreads.wait()
			rightGifImageView.animate(withGIFNamed: "giphy")
			semaphoreThreads.signal()
		}
	}
	
	private func _setAndActivateConstraints(leftGifSize: GifSize, rightGifSize: GifSize) {
		
//		var leftGifSizeConvertedInPoints = GifSize(width: -1, height: -1)
//		var rightGifSizeConvertedInPoints = GifSize(width: -1, height: -1)
		
//		if (leftGifSize.height != -1 && leftGifSize.width != -1 && rightGifSize.height != -1 && rightGifSize.width != -1) {
//			NSLayoutConstraint.activate([
//				leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: gifHorizontalOffset),
//				leftView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: gifVerticalOffset),
//				leftView.widthAnchor.constraint(equalToConstant: CGFloat(leftGifSize.width)),
//				leftView.heightAnchor.constraint(equalToConstant: CGFloat(leftGifSize.height)),
//
//				rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gifHorizontalOffset),
//				rightView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: gifVerticalOffset),
//				rightView.widthAnchor.constraint(equalToConstant: CGFloat(rightGifSize.width)),
//				rightView.heightAnchor.constraint(equalToConstant: CGFloat(leftGifSize.height)),
//
//				rightGifImageView.rightAnchor.constraint(equalTo: rightView.rightAnchor, constant: 0),
//				rightGifImageView.topAnchor.constraint(equalTo: rightView.topAnchor, constant: 0),
//				rightGifImageView.widthAnchor.constraint(equalToConstant: CGFloat(rightGifSize.width)),
//				rightGifImageView.heightAnchor.constraint(equalToConstant: CGFloat(leftGifSize.height)),
//
//				leftGifImageView.leftAnchor.constraint(equalTo: leftView.leftAnchor, constant: 0),
//				leftGifImageView.topAnchor.constraint(equalTo: leftView.topAnchor, constant: 0),
//				leftGifImageView.widthAnchor.constraint(equalToConstant: CGFloat(leftGifSize.width)),
//				leftGifImageView.heightAnchor.constraint(equalToConstant: CGFloat(leftGifSize.height))
//			])
//		} else {
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
//		}
	}


// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
