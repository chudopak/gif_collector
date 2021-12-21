//
//  ViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Dispatch

class RandomGifsViewController: UITableViewController {

//	var json: String?
//	var gifURL = ""

	static private var gifArray = [Data]()
	static private var isFirstLoad = true
	static private var gifArraySize = 0
	
	private let _semaphoreArray = DispatchSemaphore(value: 1)
	private let _semaphoreThreads = DispatchSemaphore(value: 4)
	private let _semaphoreNumberOfCurrentlyLoadingGifs = DispatchSemaphore(value: 1)
	
	private var _numberOfCurrentlyLoadingGifs = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
		if (RandomGifsViewController.isFirstLoad) {
			_semaphoreArray.wait()
			RandomGifsViewController.gifArray.reserveCapacity(50)
			RandomGifsViewController.isFirstLoad = false
			_semaphoreArray.signal()
			_loadFirstGifs()
			_semaphoreArray.wait()
			RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
			_semaphoreArray.signal()
//			DispatchQueue.global().async {
//				sleep(15)
//				print(RandomGifsViewController.gifArray.count)
//			}
//
//			print(RandomGifsViewController.gifArray.count)
		}
	}

	
	private func _loadFirstGifs() {
		for i in 0..<15 {
			_semaphoreThreads.wait()
			DispatchQueue.global(qos: .userInitiated).async {
				guard let data = self._getGifData() else {
					return
				}
				
				self._semaphoreArray.wait()
				RandomGifsViewController.gifArray.append(data)
				self._semaphoreArray.signal()

				if (i % 3 == 0) {
					self._semaphoreArray.wait()
					RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
					self._semaphoreArray.signal()
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				}
			}
			_semaphoreThreads.signal()
		}
	}
	
	private func _loadTwoGifs() {
		for i in 0..<2 {
			_semaphoreThreads.wait()
			DispatchQueue.global(qos: .userInitiated).async {
				self._semaphoreNumberOfCurrentlyLoadingGifs.wait()
				self._numberOfCurrentlyLoadingGifs += 1
				self._semaphoreNumberOfCurrentlyLoadingGifs.signal()

				guard let data = self._getGifData() else {
					return
				}
				self._semaphoreArray.wait()
				RandomGifsViewController.gifArray.append(data)
				self._semaphoreArray.signal()
				
				if (i == 1) {
					self._semaphoreArray.wait()
					RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
					self._semaphoreArray.signal()
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				}
				self._semaphoreNumberOfCurrentlyLoadingGifs.wait()
				self._numberOfCurrentlyLoadingGifs -= 1
				self._semaphoreNumberOfCurrentlyLoadingGifs.signal()
			}
			_semaphoreThreads.signal()
			
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if (RandomGifsViewController.gifArraySize < 10) {
			return (5)
		}
		return (RandomGifsViewController.gifArraySize / 2)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GifTableViewCell", for: indexPath) as! GifTableViewCell

		var leftGif: Data?
		var rightGif: Data?
		let gifForRow = indexPath.row * 2

		cell.selectionStyle = .none

		_semaphoreNumberOfCurrentlyLoadingGifs.wait()
		print(_numberOfCurrentlyLoadingGifs)
		if (RandomGifsViewController.gifArraySize > 14
				&& gifForRow + 6 >= RandomGifsViewController.gifArraySize
				&& _numberOfCurrentlyLoadingGifs < 5) {
			_loadTwoGifs()
		}
		_semaphoreNumberOfCurrentlyLoadingGifs.signal()

		_semaphoreArray.wait()
		if (gifForRow < RandomGifsViewController.gifArray.count) {
			leftGif = RandomGifsViewController.gifArray[gifForRow]
		}
		if (gifForRow + 1 < RandomGifsViewController.gifArray.count) {
			rightGif = RandomGifsViewController.gifArray[gifForRow + 1]
		}
		_semaphoreArray.signal()

		cell.configureGifs(leftGif: leftGif,
						   rightGif: rightGif,
						   semaphoreThreads: _semaphoreThreads)
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
		
		guard let original = images["original"] as? [String: Any] else {
			print("Expectred 'original' dictionary")
			return (nil)
		}

		return (original["url"] as? String)
	}
	
	private func _getGifData() -> Data? {
		guard let json = _getJSONData() else {
			return (nil)
		}
		guard let url = _parseGifURLFromJSON(json: json) else {
			return (nil)
		}
		guard let gifURL = URL(string: url) else {
			return (nil)
		}
		guard let data = try? Data(contentsOf: gifURL) else {
			return (nil)
		}
		return (data)
	}
}

