//
//  GifTableViewCell.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Gifu

class GifTableViewCell: UITableViewCell {
	
	let gif =  "https://media2.giphy.com/media/YhW0qsOoz8vb37vxFO/200w.gif?cid=ecf05e47dfrudf6kvbsem8rq2zzu3zzrrsc70s2trx4tbvr8&rid=200w.gif&ct=g"
	
	let leftGifImageView: GIFImageView = {
		let image = GIFImageView()
		image.contentMode = .scaleAspectFill
		image.bounds.size.width = UIScreen.main.bounds.width / 2 - 15
		image.bounds.size.height = image.bounds.size.width
		image.layer.cornerRadius = 3.0
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
	
	public func configureGifs() {
		contentView.addSubview(rightGifImageView)
		contentView.addSubview(leftGifImageView)
		setAndActivateConstraints()
//		leftGifImageView.layer.cornerRadius = 3
//		rightGifImageView.layer.cornerRadius = 3
		leftGifImageView.animate(withGIFNamed: "giphy")
		let gifURL = URL(string: gif)!
		rightGifImageView.animate(withGIFURL: gifURL)
	}
	
	public func setAndActivateConstraints() {
		NSLayoutConstraint.activate([
			leftGifImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
			leftGifImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			leftGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			leftGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			
			rightGifImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
			rightGifImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			rightGifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15),
			rightGifImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 15)
		])
	}

// MARK: - static attributes
	static let identifier = "GifTableViewCell"

}
