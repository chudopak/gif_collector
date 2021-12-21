//
//  GifData.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/21/21.
//

import Foundation
import UIKit

struct GifSize {
	var width: Int
	var height: Int
}

struct GifData {
	let gif: Data
	let pixelSize: GifSize
	let pointSize: GifSize = GifSize(width: -1, height: -1)
	
	init(data: Data, width: Int, height: Int) {
		gif = data
		pixelSize = GifSize(width: width, height: height)
	}
	
	init(data: Data) {
		self.init(data: data, width: -1, height: -1)
	}
}
