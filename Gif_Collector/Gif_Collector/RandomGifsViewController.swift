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
	private var tag = ""
	
	lazy var refreshToPull: UIRefreshControl = {
		var refreshControll = UIRefreshControl()
		refreshControll.addTarget(self, action: #selector(_refreshControllerCalled), for: .valueChanged)
		return (refreshControll)
	} ()
	
	lazy var refreshButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		let titleColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
			}
		}
		button.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
			}
		}
		button.setTitleColor(titleColor, for: .normal)
		button.setImage(UIImage(named: "refresh"), for: .normal)
		button.addTarget(self, action: #selector(_refreshButtonPressed), for: .touchUpInside)
		return (button)
	} ()

	private let topBarView: UIView = {
		let v = UIView()
		v.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topBarHeight)
		return (v)
	}()
	
	lazy var searchBar: UISearchBar = {
		var searchBar = UISearchBar()
		searchBar.searchBarStyle = .default
		searchBar.placeholder = "Search for pets"
		searchBar.isTranslucent = true
		searchBar.backgroundImage = UIImage()
		searchBar.barTintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		searchBar.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
			}
		}
		searchBar.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		return (searchBar)
	} ()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setUpTableView()
		_setUpTopBarView()
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
	
	private func _setUpTopBarView() {
		view.addSubview(topBarView)
		topBarView.addSubview(searchBar)
		topBarView.addSubview(refreshButton)
		searchBar.delegate = self
		if let textField = searchBar.value(forKey: "searchField") as? UITextField {
			textField.backgroundColor = UIColor { tc in
				switch tc.userInterfaceStyle {
				case .dark:
					return (UIColor(red: 0.19, green: 0.195, blue: 0.199, alpha: 1))
				default:
					return (UIColor(red: 0.884, green: 0.911, blue: 0.478, alpha: 1))
				}
			}
		}
		searchBar.frame = CGRect(x: 0,
								 y: 0,
								 width: UIScreen.main.bounds.width - topBarHeight,
								 height: topBarHeight)
		refreshButton.frame = CGRect(x: UIScreen.main.bounds.width - topBarHeight,
									 y: 0,
									 width: topBarHeight,
									 height: topBarHeight)
	}
	
	private func _setUpTableView() {
		tableView.refreshControl = refreshToPull
		tableView.separatorColor = .none
		tableView.separatorStyle = .none
		tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
	}

	@objc private func _refreshControllerCalled(sender: UIRefreshControl) {
		_refresh(usingRefrechControl: true)
	}
	
	@objc private func _refreshButtonPressed() {
		_refresh(usingRefrechControl: false)
	}
	
	private func _refresh(usingRefrechControl: Bool) {
		_semaphoreArray.wait()
		RandomGifsViewController.gifArray.removeAll(keepingCapacity: true)
		_semaphoreArray.signal()
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = false
		refreshButton.isEnabled = false
		searchTag = tag
		
		_semaphoreThreads.wait()
		DispatchQueue.global(qos: .background).async {
			while (true) {
				usleep(500000)
				self._semaphoreArray.wait()
				if (RandomGifsViewController.gifArray.count >= 10) {
					self._semaphoreArray.signal()
					DispatchQueue.main.async {
						self.refreshToPull.endRefreshing()
						self.refreshButton.isEnabled = true
					}
					break
				}
				self._semaphoreArray.signal()
			}
		}
		_semaphoreThreads.signal()
		_loadFirstGifs()
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
	
	private func _convertSearchTagToLinkFormat(tag: String) -> String {

		let finalTag: String = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return (finalTag)
	}
}

extension RandomGifsViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = false
		tag = _convertSearchTagToLinkFormat(tag: searchBar.text!)
		searchTag = tag
		tag = ""
		searchBar.text! = ""
		_semaphoreArray.wait()
		RandomGifsViewController.gifArray.removeAll(keepingCapacity: true)
		_semaphoreArray.signal()
		_loadFirstGifs()
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

//		finalTag = finalTag.replacingOccurrences(of: "%", with: "%25")
//
//		finalTag = finalTag.replacingOccurrences(of: "\'", with: "%27", options: .literal, range: nil)
//		finalTag = finalTag.replacingOccurrences(of: "'", with: "%27")
//		finalTag = finalTag.replacingOccurrences(of: "+", with: "%2B")
//		finalTag = finalTag.replacingOccurrences(of: " ", with: "+")
//		finalTag = finalTag.replacingOccurrences(of: "/", with: "%2F")
//		finalTag = finalTag.replacingOccurrences(of: "?", with: "%3F")
//		finalTag = finalTag.replacingOccurrences(of: ">", with: "%3E")
//		finalTag = finalTag.replacingOccurrences(of: "<", with: "%3C")
//		finalTag = finalTag.replacingOccurrences(of: ",", with: "%2C")
//		finalTag = finalTag.replacingOccurrences(of: "`", with: "%60")
//		finalTag = finalTag.replacingOccurrences(of: "~", with: "%7E")
//		finalTag = finalTag.replacingOccurrences(of: "=", with: "%3D")
//		finalTag = finalTag.replacingOccurrences(of: "!", with: "%21")
//		finalTag = finalTag.replacingOccurrences(of: "@", with: "%40")
//		finalTag = finalTag.replacingOccurrences(of: "#", with: "%23")
//		finalTag = finalTag.replacingOccurrences(of: "$", with: "%24")
//		finalTag = finalTag.replacingOccurrences(of: "^", with: "%5E")
//		finalTag = finalTag.replacingOccurrences(of: "&", with: "%26")
//		finalTag = finalTag.replacingOccurrences(of: "(", with: "%28")
//		finalTag = finalTag.replacingOccurrences(of: ")", with: "%29")
//		finalTag = finalTag.replacingOccurrences(of: "{", with: "%7B")
//		finalTag = finalTag.replacingOccurrences(of: "}", with: "%7D")
//		finalTag = finalTag.replacingOccurrences(of: "[", with: "%5B")
//		finalTag = finalTag.replacingOccurrences(of: "]", with: "%5D")
//		finalTag = finalTag.replacingOccurrences(of: "|", with: "%7C")
//		finalTag = finalTag.replacingOccurrences(of: "\\", with: "%5C")
//		finalTag = finalTag.replacingOccurrences(of: ";", with: "%3B")
//		finalTag = finalTag.replacingOccurrences(of: ":", with: "%3A")
//
//		finalTag = finalTag.replacingOccurrences(of: "\"", with: "%22")
//		finalTag = finalTag.replacingOccurrences(of: ":", with: "%3A")
