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
	
	private let parse = ParseJSON()
	
	private var searchTag = ""

	private let topBarView: UIView = {
		let v = UIView()
		v.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
		v.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1))
			default:
				return (UIColor(red: 0.91, green: 0.941, blue: 0.73, alpha: 1))
			}
		}
		return (v)
	}()
	
	lazy var searchBar: UISearchBar = {
		var searchBar = UISearchBar()
		searchBar.searchBarStyle = .default
		searchBar.placeholder = "Search..."
		searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
		searchBar.isTranslucent = false
		return (searchBar)
	} ()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setTopBarView()
		tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		if (RandomGifsViewController.isFirstLoad) {
			_semaphoreArray.wait()
			RandomGifsViewController.gifArray.reserveCapacity(50)
			RandomGifsViewController.isFirstLoad = false
			_semaphoreArray.signal()
			_loadFirstGifs()
			_semaphoreArray.wait()
			RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
			_semaphoreArray.signal()
		}
	}

	private func _setTopBarView() {
		view.addSubview(topBarView)
		topBarView.addSubview(searchBar)
		searchBar.delegate = self
	}
	
	private func _loadFirstGifs() {
		for _ in 0..<10 {
			_semaphoreThreads.wait()
			DispatchQueue.global(qos: .userInitiated).async {
				guard let leftGifData = self.parse.getGifData(searchURL: randomGifAPILink + self.searchTag + endLink) else {
					return
				}
				guard let rightGifData = self.parse.getGifData(searchURL: randomGifAPILink + self.searchTag + endLink) else {
					return
				}

				let rowGifs = RowGifsData(leftGif: leftGifData, rightGif: rightGifData)
				
				self._semaphoreArray.wait()
				RandomGifsViewController.gifArray.append(rowGifs)
				self._semaphoreArray.signal()

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

		var gifs: RowGifsData?
		var topBarOffset: CGFloat = 0
		if (indexPath.row == 0) {
			topBarOffset = topBarView.bounds.size.height
		}
		cell.selectionStyle = .none

		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController.gifArray.count) {
			gifs = RandomGifsViewController.gifArray[indexPath.row]
		}
		_semaphoreArray.signal()

		cell.configureGifs(gifs: gifs, topBarOffset: topBarOffset)
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var cellHeight: CGFloat = -1
		var searchBarOffset: CGFloat = 0
		if (indexPath.row == 0) {
			searchBarOffset = topBarView.bounds.size.height
		}
		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController.gifArray.count) {
			cellHeight = RandomGifsViewController.gifArray[indexPath.row].cellHeight
		}
		_semaphoreArray.signal()
		if (cellHeight != -1) {
			return (cellHeight + searchBarOffset)
		}
		return (UIScreen.main.bounds.width / 2 + 5 + searchBarOffset)
	}
	
	private func _reloadGifList() {
		_semaphoreArray.wait()
		RandomGifsViewController.gifArray.removeAll()
		_semaphoreArray.signal()
		_loadFirstGifs()
		
	}
}

extension RandomGifsViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = false
		searchTag = searchBar.text!
		searchBar.text! = ""
		_reloadGifList()
		print("Start searching..", searchTag, randomGifAPILink + searchTag + endLink)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
		searchBar.resignFirstResponder()
		searchBar.text! = ""
		print("finish searching..")
	}
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = true
		print("realy start Editing")
	}
}



//				print("width - \(rowGifs.leftGif.pixelSize.width) height - \(rowGifs.leftGif.pixelSize.height) cell height - \(rowGifs.cellHeight)", """
//
//					new Point Size width -  \(rowGifs.leftGif.pointSize.width) height - \(rowGifs.leftGif.pointSize.height)
//
//					""")
//				print("width - \(rowGifs.rightGif.pixelSize.width) height - \(rowGifs.rightGif.pixelSize.height) cell height - \(rowGifs.cellHeight)", """
//
//					new Point Size width -  \(rowGifs.rightGif.pointSize.width) height - \(rowGifs.rightGif.pointSize.height)
//
//					""")
