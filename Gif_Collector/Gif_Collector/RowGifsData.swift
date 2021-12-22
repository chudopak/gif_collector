//
//  GifData.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/21/21.
//

import Foundation
import UIKit

struct GifSize {
	var width: CGFloat
	var height: CGFloat
}

struct GifData {
	let gif: Data
	let pixelSize: GifSize
	var pointSize: GifSize = GifSize(width: -1, height: -1)
	
	init(data: Data, width: CGFloat, height: CGFloat) {
		gif = data
		pixelSize = GifSize(width: width, height: height)
	}
	
	init(copySelf: GifData) {
		self.gif = copySelf.gif
		self.pixelSize = copySelf.pixelSize
		self.pointSize = copySelf.pointSize
	}
	
	init(data: Data) {
		self.init(data: data, width: -1, height: -1)
	}
}

class RowGifsData {
	var leftGif: GifData
	var rightGif: GifData
	var cellHeight: CGFloat = -1
	private let _controlMaxRatio: CGFloat = 1.3
	
	init(leftGif: GifData, rightGif: GifData) {
		self.leftGif = leftGif
		self.rightGif = rightGif
		self.leftGif.pointSize = _getLeftGifPointSize(leftGifData: leftGif,
													 rightGifData: rightGif)
		self.rightGif.pointSize = _getRightGifPointSize(leftGifData: leftGif,
															rightGifData: rightGif)
		self.cellHeight = _getCellHeight(leftGifSize: self.leftGif.pointSize,
										 rightGifSize: self.rightGif.pointSize)
	}
	
	private func _getCellHeight(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		if (leftGifSize.height > rightGifSize.height) {
			return (leftGifSize.height + 20.0)
		} else {
			return (rightGifSize.height + 20.0)
		}
	}
	
	private func _getLeftViewWidth(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		if (leftGifSize.width == -1 || leftGifSize.height == -1) {
			return (-1)
		}
		
		let widthOfTwoGifs = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
		let ratio: CGFloat = leftGifSize.width / rightGifSize.width
		if (ratio > _controlMaxRatio) {
			return (widthOfTwoGifs / 2 * _controlMaxRatio)
		}
		return (widthOfTwoGifs / 2 * ratio)
	}
	
	private func _getRightViewWidth(leftGifSize: GifSize, rightGifSize: GifSize) -> CGFloat {
		if (rightGifSize.width == -1 || rightGifSize.height == -1) {
			return (-1)
		}

		let widthOfTwoGifs = UIScreen.main.bounds.width - 3 * gifHorizontalOffset
		if (leftGifSize.width == -1 || leftGifSize.height == -1) {
			let ratio: CGFloat = rightGifSize.width / leftGifSize.width
			if (ratio > _controlMaxRatio) {
				return (widthOfTwoGifs / 2 * _controlMaxRatio)
			} else {
				return (widthOfTwoGifs / 2 * ratio)
			}
		}
		return (widthOfTwoGifs - _getLeftViewWidth(leftGifSize: leftGifSize, rightGifSize: rightGifSize))
	}
	
	private func _getLeftGifPointSize(leftGifData: GifData, rightGifData: GifData) -> GifSize {
		var leftGifWidth: CGFloat = -1
		var leftGifHeight: CGFloat = -1
		leftGifWidth = _getLeftViewWidth(leftGifSize: leftGifData.pixelSize,
											   rightGifSize: rightGifData.pixelSize)
		leftGifHeight = leftGifData.pixelSize.height / leftGifData.pixelSize.width * leftGifWidth
		return (GifSize(width:leftGifWidth, height: leftGifHeight))
	}

	private func _getRightGifPointSize(leftGifData: GifData, rightGifData: GifData) -> GifSize {
		var rightGifWidth: CGFloat = -1
		var rightGifHeight: CGFloat = -1
		rightGifWidth = _getRightViewWidth(leftGifSize: leftGifData.pixelSize,
											   rightGifSize: rightGifData.pixelSize)
		rightGifHeight = rightGifData.pixelSize.height / rightGifData.pixelSize.width * rightGifWidth
		return (GifSize(width: rightGifWidth, height: rightGifHeight))
	}
}
