//
//  GifTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Gifu


class GifTableViewCell: UITableViewCell {
	
	var gif = ""
	
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
	
	public func configureGifs(leftGif: Data?, rightGif: Data?, semaphoreThreads: DispatchSemaphore ) {
		leftView.addSubview(leftGifImageView)
		rightView.addSubview(rightGifImageView)
		contentView.addSubview(rightView)
		contentView.addSubview(leftView)
		setAndActivateConstraints()

		semaphoreThreads.wait()
		if let leftGif = leftGif {
			leftGifImageView.animate(withGIFData: leftGif)
		} else {
			leftGifImageView.animate(withGIFNamed: "giphy")
		}
		semaphoreThreads.signal()
		
		semaphoreThreads.wait()
		if let rightGif = rightGif {
			rightGifImageView.animate(withGIFData: rightGif)
		} else {
			rightGifImageView.animate(withGIFNamed: "giphy")
		}
		semaphoreThreads.signal()
	}
	
	public func setAndActivateConstraints() {
		NSLayoutConstraint.activate([
			leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
			leftView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			leftView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			leftView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			
			rightView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
			rightView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
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


// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
