//
//  ViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit

class RandomGifsViewController: UITableViewController {

	var json: String?
	var gifURL = ""

	static private var gifArray = [Data]()
	static private var isFirstLoad = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
		if (RandomGifsViewController.isFirstLoad) {
			RandomGifsViewController.gifArray.reserveCapacity(50)
			RandomGifsViewController.isFirstLoad = false
			for i in 0..<15 {
				json = _getJSONData()
				if let json = json {
					if let url = _parseGifURLFromJSON(json: json) {
						gifURL = url
						print(url)
					} else {
						print("SHit")
					}
				}
			}
		}
	}

	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (3)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GifTableViewCell", for: indexPath) as! GifTableViewCell

		cell.selectionStyle = .none
		cell.configureGifs(gifURL: gifURL)
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (UIScreen.main.bounds.width / 2 + 5)
	}
	
	private func _giphyURL(serachURL: String) -> URL? {
		let url = URL(string: "https://api.giphy.com/v1/gifs/random?api_key=4iYL33Ywl2xS59XUL40sPHH9cjjVnTfE&tag=&rating=r")
		return (url)
	}
	
	private func _performGyphyRequest(with url: URL) -> String? {
		do {
			return (try String(contentsOf: url, encoding: .utf8))
		} catch {
			print("Download Error: \(error)")
			return (nil)
		}
	}
	
	private func _getJSONData() -> String? {
		guard let url = _giphyURL(serachURL: "") else {
			return (nil)
		}
		guard let data = _performGyphyRequest(with: url) else {
			return (nil)
		}
		return (data)
	}
	
	private func _parseGifURLFromJSON(json: String) -> String? {
		
		guard let data = json.data(using: .utf8, allowLossyConversion: false) else {
			return (nil)
		}
		
		var jsonData: [String: Any]?
		
		do {
			jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		} catch {
			print("JSON ERROR \(error)")
			return (nil)
		}
		
		guard let jsonDataUnwrapped = jsonData else {
			return (nil)
		}

		guard let data = jsonDataUnwrapped["data"] as? [String: Any] else {
			print("Expectred 'data' dictionary")
			return (nil)
		}
		
		guard let images = data["images"] as? [String: Any] else {
			print("Expectred 'images' dictionary")
			return (nil)
		}
//		print(images)
		
		guard let original = images["original"] as? [String: Any] else {
			print("Expectred 'original' dictionary")
			return (nil)
		}

		return (original["url"] as? String)
	}
}

