//
//  ParseJSON.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/21/21.
//

import Foundation
import UIKit

class ParseJSON {
	
	func parseGifInfoFromJSON(json: String) -> [String: Any]? {
		
		guard let jDataUnparsed = json.data(using: .utf8, allowLossyConversion: false) else {
			return (nil)
		}
		
		var jsonData: [String: Any]?
		
		do {
			jsonData = try JSONSerialization.jsonObject(with: jDataUnparsed, options: []) as? [String: Any]
		} catch {
			print("JSON ERROR \(error)")
			return (nil)
		}
		
		guard let jsonDataUnwrapped = jsonData else {
			return (nil)
		}
//		print(jsonDataUnwrapped)

		guard let data = jsonDataUnwrapped["data"] as? [String: Any] else {
			print("Expectred 'data' dictionary")
			return (nil)
		}
		
		guard let images = data["images"] as? [String: Any] else {
			print("Expectred 'images' dictionary")
			return (nil)
		}
		
		guard let gifData = images["downsized"] as? [String: Any] else {
			print("Expectred 'downsized' dictionary")
			return (nil)
		}
//		print(gifData)
		return (gifData)
	}
	
	func performGyphyRequest(with url: URL) -> String? {
		do {
			return (try String(contentsOf: url, encoding: .utf8))
		} catch {
			print("Download Error: \(error)")
			return (nil)
		}
	}
	
	func giphyURL(searchURL: String) -> URL? {
		let url = URL(string: searchURL)
		return (url)
	}
	
	func getJSONData(searchURL: String) -> String? {
		guard let url = giphyURL(searchURL: searchURL) else {
			return (nil)
		}
		guard let data = performGyphyRequest(with: url) else {
			return (nil)
		}
		return (data)
	}
	
	func getGifData(searchURL: String) -> GifData? {
		guard let json = getJSONData(searchURL: searchURL) else {
			return (nil)
		}
		guard let gifInfo = parseGifInfoFromJSON(json: json) else {
			return (nil)
		}
		
		guard let url = gifInfo["url"] as? String else {
			return (nil)
		}
		
		guard let gifURL = URL(string: url) else {
			return (nil)
		}
		guard let data = try? Data(contentsOf: gifURL) else {
			return (nil)
		}
		
		var width: Int = -1
		var height: Int = -1
		
		if let w = gifInfo["width"] as? String {
			width = Int(w) ?? -1
		}
		if let h = gifInfo["height"] as? String {
			height = Int(h) ?? -1
		}
		return (GifData(data: data, width: CGFloat(width), height: CGFloat(height)))
	}
}
