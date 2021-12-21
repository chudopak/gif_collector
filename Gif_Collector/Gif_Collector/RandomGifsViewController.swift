//
//  ViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Dispatch

class RandomGifsViewController: UITableViewController {

	static private var gifArray = [RowGifsData]()
	static private var isFirstLoad = true
	static private var gifArraySize = 0
	
	private let _semaphoreArray = DispatchSemaphore(value: 1)
	private let _semaphoreThreads = DispatchSemaphore(value: 4)
	private let _semaphoreLoadGifs = DispatchSemaphore(value: 1)
	
	private var _loadedGifs = 0
	private let parse = ParseJSON()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(UIScreen.main.bounds.width)
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
		for _ in 0..<10 {
			_semaphoreThreads.wait()
			DispatchQueue.global(qos: .userInitiated).async {
				guard let leftGifData = self.parse.getGifData(searchURL: randomGifAPILink) else {
					return
				}
				guard let rightGifData = self.parse.getGifData(searchURL: randomGifAPILink) else {
					return
				}

				let rowGifs = RowGifsData(leftGif: leftGifData, rightGif: rightGifData)
				
				self._semaphoreArray.wait()
				RandomGifsViewController.gifArray.append(rowGifs)
				print("width - \(rowGifs.leftGif.pixelSize.width) height - \(rowGifs.leftGif.pixelSize.height) cell height - \(rowGifs.cellHeight)", """
					
					new Point Size width -  \(rowGifs.leftGif.pointSize.width) height - \(rowGifs.leftGif.pointSize.height)
					
					""")
				print("width - \(rowGifs.rightGif.pixelSize.width) height - \(rowGifs.rightGif.pixelSize.height) cell height - \(rowGifs.cellHeight)", """
					
					new Point Size width -  \(rowGifs.rightGif.pointSize.width) height - \(rowGifs.rightGif.pointSize.height)
					
					""")
				self._semaphoreArray.signal()
				
				self._semaphoreLoadGifs.wait()
				self._loadedGifs += 2
				self._semaphoreLoadGifs.signal()

				self._semaphoreArray.wait()
				RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
				self._semaphoreArray.signal()
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
			_semaphoreThreads.signal()
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if (RandomGifsViewController.gifArraySize < 8) {
			return (4)
		}
		return (RandomGifsViewController.gifArraySize)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GifTableViewCell", for: indexPath) as! GifTableViewCell

//		print("CellForRow \(indexPath.row)")
		var gifs: RowGifsData?

		cell.selectionStyle = .none

		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController.gifArray.count) {
			gifs = RandomGifsViewController.gifArray[indexPath.row]
		}
		_semaphoreArray.signal()

		cell.configureGifs(gifs: gifs,
						   semaphoreThreads: _semaphoreThreads)
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		print("HeightForROw \(indexPath.row)")
//		var cellHeight: CGFloat = -1
//		let gifForRow = indexPath.row * 2
//		_semaphoreArray.wait()
//		if (gifForRow < RandomGifsViewController.gifArray.count) {
//			cellHeight = RandomGifsViewController.gifArray[gifForRow].cellHeight
//		}
//		_semaphoreArray.signal()
//		if (cellHeight != -1) {
//			return (cellHeight)
//		}
		return (UIScreen.main.bounds.width / 2 + 5)
	}
}

