//
//  ViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Dispatch

class RandomGifsViewController: UITableViewController {

	static private var gifArray = [GifData]()
	static private var isFirstLoad = true
	static private var gifArraySize = 0
	
	private let _semaphoreArray = DispatchSemaphore(value: 1)
	private let _semaphoreThreads = DispatchSemaphore(value: 4)
	private let _semaphoreLoadGifs = DispatchSemaphore(value: 1)
	
	private var _loadedGifs = 0
	private let parse = ParseJSON()
	
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
//				sleep(30)
//				print(RandomGifsViewController.gifArray.count)
//			}
		}
	}

	
	private func _loadFirstGifs() {
		for _ in 0..<20 {
			_semaphoreThreads.wait()
			DispatchQueue.global(qos: .userInitiated).async {
				guard let gifData = self.parse.getGifData(searchURL: randomGifAPILink) else {
					return
				}
				
				self._semaphoreArray.wait()
				RandomGifsViewController.gifArray.append(gifData)
				print("width - \(gifData.pixelSize.width) height - \(gifData.pixelSize.height)")
				self._semaphoreArray.signal()
				
				self._semaphoreLoadGifs.wait()
				self._loadedGifs += 1
				self._semaphoreLoadGifs.signal()

				if (self._loadedGifs % 4 == 0) {
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
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if (RandomGifsViewController.gifArraySize < 8) {
			return (4)
		}
		return (RandomGifsViewController.gifArraySize / 2)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GifTableViewCell", for: indexPath) as! GifTableViewCell

		print("CellForRow \(indexPath.row)")
		var leftGif: GifData?
		var rightGif: GifData?
		let gifForRow = indexPath.row * 2

		cell.selectionStyle = .none

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
//		print("HeightForROw \(indexPath.row)")
//		var leftGif: GifData?
//		var rightGif: GifData?
//		let gifForRow = indexPath.row * 2
//		_semaphoreArray.wait()
//		if (gifForRow < RandomGifsViewController.gifArray.count) {
//			leftGif = RandomGifsViewController.gifArray[gifForRow]
//		}
//		if (gifForRow + 1 < RandomGifsViewController.gifArray.count) {
//			rightGif = RandomGifsViewController.gifArray[gifForRow + 1]
//		}
//		_semaphoreArray.signal()
//		return (getCellHeight(leftGifSize: leftGif?.size ?? GifSize(width: -1, height: -1)
//							  , rightGifSize: rightGif?.size ?? GifSize(width: -1, height: -1)))
		return (UIScreen.main.bounds.width / 2 + 5)
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
}

