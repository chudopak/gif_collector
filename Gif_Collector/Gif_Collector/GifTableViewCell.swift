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
		v.backgroundColor = .green
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
		v.backgroundColor = .red
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
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	public func configureGifs(gifs: RowGifsData?) {
		leftView.addSubview(leftGifImageView)
		rightView.addSubview(rightGifImageView)
		contentView.addSubview(rightView)
		contentView.addSubview(leftView)
		_setViewsSize(leftGifSize: gifs?.leftGif.pointSize ?? GifSize(width: -1, height: -1),
								   rightGifSize: gifs?.rightGif.pointSize ?? GifSize(width: -1, height: -1))
		_setViewsPosition()

		if let gifs = gifs {
			leftGifImageView.animate(withGIFData: gifs.leftGif.gif)
			rightGifImageView.animate(withGIFData: gifs.rightGif.gif)
		} else {
			leftGifImageView.animate(withGIFNamed: "giphy")
			rightGifImageView.animate(withGIFNamed: "giphy")
		}
	}
	
	private func _setViewsPosition() {
		leftView.frame.origin = CGPoint(
				x: gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - leftView.bounds.size.height / 2)
		rightView.frame.origin = CGPoint(
				x: contentView.bounds.size.width - rightView.bounds.size.width - gifHorizontalOffset,
				y: contentView.bounds.size.height / 2 - rightView.bounds.size.height / 2)
		leftGifImageView.frame.origin = CGPoint(x: 0, y: 0)
		rightGifImageView.frame.origin = CGPoint(x: 0, y: 0)
	}

	private func _setViewsSize(leftGifSize: GifSize, rightGifSize: GifSize) {
		if (leftGifSize.height != -1 && leftGifSize.width != -1 && rightGifSize.height != -1 && rightGifSize.width != -1) {
			leftView.bounds.size.width = leftGifSize.width
			leftView.bounds.size.height = leftGifSize.height
			rightView.bounds.size.width = rightGifSize.width
			rightView.bounds.size.height = rightGifSize.height
			leftGifImageView.bounds.size.width = leftGifSize.width
			leftGifImageView.bounds.size.height = leftGifSize.height
			rightGifImageView.bounds.size.width = rightGifSize.width
			rightGifImageView.bounds.size.height = rightGifSize.height
		} else {
			leftView.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
			leftView.bounds.size.height = leftView.bounds.size.width
			rightView.bounds.size.width = leftView.bounds.size.width
			rightView.bounds.size.height = leftView.bounds.size.width
			leftGifImageView.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
			leftGifImageView.bounds.size.height = leftView.bounds.size.width
			rightGifImageView.bounds.size.width = leftView.bounds.size.width
			rightGifImageView.bounds.size.height = leftView.bounds.size.width
		}
	}
	
	private func _setAndActivateConstraints(leftGifSize: GifSize, rightGifSize: GifSize) {
		
		NSLayoutConstraint.activate([
				leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: gifHorizontalOffset),
				leftView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

				rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gifHorizontalOffset),
				rightView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

				rightGifImageView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
				rightGifImageView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),

				leftGifImageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
				leftGifImageView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor)
		])
		
//		if (leftGifSize.height != -1 && leftGifSize.width != -1 && rightGifSize.height != -1 && rightGifSize.width != -1) {
//			_deactivateLoadingGifConstraints()
//			NSLayoutConstraint.activate([
//				leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: gifHorizontalOffset),
//				leftView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//				leftView.widthAnchor.constraint(equalToConstant: leftGifSize.width),
//				leftView.heightAnchor.constraint(equalToConstant: leftGifSize.height),
//
//				rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gifHorizontalOffset),
//				rightView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//				rightView.widthAnchor.constraint(equalToConstant: rightGifSize.width),
//				rightView.heightAnchor.constraint(equalToConstant: rightGifSize.height),
//
//				rightGifImageView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
//				rightGifImageView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
//				rightGifImageView.widthAnchor.constraint(equalToConstant: rightGifSize.width),
//				rightGifImageView.heightAnchor.constraint(equalToConstant: rightGifSize.height),
//
//				leftGifImageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
//				leftGifImageView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
//				leftGifImageView.widthAnchor.constraint(equalToConstant: leftGifSize.width),
//				leftGifImageView.heightAnchor.constraint(equalToConstant: leftGifSize.height)
//			])
//		} else {
//			_deactivateExistedGifConstraint(leftGifSize: leftGifSize, rightGifSize: rightGifSize)
//			_activateLoadingGifConstraints()
//		}
//		_deactivateLoadingGifConstraints()
//		_activateLoadingGifConstraints()
	}
	
	private func _activateLoadingGifConstraints() {
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
	
	private func _deactivateLoadingGifConstraints() {
		NSLayoutConstraint.deactivate([
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
	
	private func _deactivateExistedGifConstraint(leftGifSize: GifSize, rightGifSize: GifSize) {
		NSLayoutConstraint.deactivate([
		leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: gifHorizontalOffset),
		leftView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		leftView.widthAnchor.constraint(equalToConstant: leftGifSize.width),
		leftView.heightAnchor.constraint(equalToConstant: leftGifSize.height),
		
		rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gifHorizontalOffset),
		rightView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		rightView.widthAnchor.constraint(equalToConstant: rightGifSize.width),
		rightView.heightAnchor.constraint(equalToConstant: rightGifSize.height),
		
		rightGifImageView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
		rightGifImageView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
		rightGifImageView.widthAnchor.constraint(equalToConstant: rightGifSize.width),
		rightGifImageView.heightAnchor.constraint(equalToConstant: rightGifSize.height),
		
		leftGifImageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
		leftGifImageView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
		leftGifImageView.widthAnchor.constraint(equalToConstant: leftGifSize.width),
		leftGifImageView.heightAnchor.constraint(equalToConstant: leftGifSize.height)
		])
	}


// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
