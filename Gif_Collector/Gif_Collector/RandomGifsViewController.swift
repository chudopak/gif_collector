//
//  ViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import Dispatch
import CoreData

class RandomGifsViewController: UITableViewController {

	var managedObjectContext: NSManagedObjectContext!
	
	static private var gifArray = [RowGifsData]()
	static private var isFirstLoad = true
	static private var gifArraySize = 0
	
	private let _semaphoreArray = DispatchSemaphore(value: 1)
	private let _semaphoreThreads = DispatchSemaphore(value: 2)
	private let _semaphoreIsAllGifsLoaded = DispatchSemaphore(value: 1)
	
	private var _isAllGifsLoaded = true
	
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
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		button.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColor)
			default:
				return (lightThemeTintColor)
			}
		}
		let refreshImageConfig = UIImage.SymbolConfiguration(pointSize: topBarHeight * 0.6,
															 weight: .regular,
															 scale: .medium)
		button.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: refreshImageConfig), for: .normal)
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
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		searchBar.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeTintColor)
			default:
				return (lightThemeTintColor)
			}
		}
		searchBar.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		return (searchBar)
	} ()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setTableView()
		_setTopBarView()
		if (RandomGifsViewController.isFirstLoad) {
			_semaphoreArray.wait()
			RandomGifsViewController.gifArray.reserveCapacity(50)
			RandomGifsViewController.isFirstLoad = false
			_semaphoreArray.signal()
			_refresh(refreshControlState: false)
			_semaphoreArray.wait()
			RandomGifsViewController.gifArraySize = RandomGifsViewController.gifArray.count
			_semaphoreArray.signal()
		}
	}
	
	private func _setTopBarView() {
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
					return (UIColor(red: 0.945, green: 0.894, blue: 0.734, alpha: 1))
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
	
	private func _setTableView() {
		tableView.refreshControl = refreshToPull
		tableView.separatorColor = .none
		tableView.separatorStyle = .none
		tableView.register(GifTableViewCell.self, forCellReuseIdentifier: GifTableViewCell.identifier)
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (darkThemeBackgroundColor)
			default:
				return (lightThemeBackgroundColor)
			}
		}
		tableView.allowsSelection = true
	}

	@objc private func _refreshControllerCalled(sender: UIRefreshControl) {
		_semaphoreIsAllGifsLoaded.wait()
		if (_isAllGifsLoaded) {
			_semaphoreIsAllGifsLoaded.signal()
			_refresh(refreshControlState: true)
			return
		}
		_semaphoreIsAllGifsLoaded.signal()
		refreshToPull.endRefreshing()
	}
	
	@objc private func _refreshButtonPressed() {
		_semaphoreIsAllGifsLoaded.wait()
		if (_isAllGifsLoaded) {
			_semaphoreIsAllGifsLoaded.signal()
			_refresh(refreshControlState: false)
			return
		}
		_semaphoreIsAllGifsLoaded.signal()
	}
	
	private func _observer(refeshControlState: Bool) {
		_semaphoreIsAllGifsLoaded.wait()
		_isAllGifsLoaded = false
		_semaphoreIsAllGifsLoaded.signal()
		
		DispatchQueue.global(qos: .background).async {
			var numberOfChecks = 0
			while (true) {
				usleep(500000)
				self._semaphoreArray.wait()
				if (RandomGifsViewController.gifArray.count >= 10 || numberOfChecks >= 60) {
					self._semaphoreArray.signal()
					DispatchQueue.main.async {
						if (refeshControlState) {
							self.refreshToPull.endRefreshing()
						}
						self.refreshButton.isEnabled = true
						
						self._semaphoreIsAllGifsLoaded.wait()
						self._isAllGifsLoaded = true
						self._semaphoreIsAllGifsLoaded.signal()
					}
					break
				}
				self._semaphoreArray.signal()
				numberOfChecks += 1
			}
		}
	}
	
	private func _refresh(refreshControlState: Bool) {
		_semaphoreArray.wait()
		RandomGifsViewController.gifArray.removeAll(keepingCapacity: true)
		_semaphoreArray.signal()
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = false
		refreshButton.isEnabled = false
		searchTag = tag
		tag = ""
		_observer(refeshControlState: refreshControlState)
		_loadFirstGifs()
	}

	private func _loadFirstGifs() {
		DispatchQueue.global(qos: .userInitiated).async {
			for _ in 0..<10 {
				self._semaphoreThreads.wait()
				DispatchQueue.global(qos: .userInitiated).async {
					guard let leftGifData = self.parse.getGifData(searchURL: randomGifAPILink + self.searchTag + endLink) else {
						print("Left gif doesn't load")
						return
					}
					guard let rightGifData = self.parse.getGifData(searchURL: randomGifAPILink + self.searchTag + endLink) else {
						print("right gif doesn't load")
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
				self._semaphoreThreads.signal()
			}
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController.gifArray.count) {
			let gifs = RandomGifsViewController.gifArray[indexPath.row]
			_semaphoreArray.signal()
			let saveItemViewController = SaveItemViewController()
			if (managedObjectContext != nil) {
				saveItemViewController.managedObjectContext = managedObjectContext
			}
			else {
				print()
				print("Bad news")
				print()
			}
			saveItemViewController.firstGif = gifs.leftGif
			saveItemViewController.secondGif = gifs.rightGif
			let navigationController = UINavigationController(rootViewController: saveItemViewController)
			navigationController.modalPresentationStyle = .fullScreen
			present(navigationController, animated: true, completion: nil)
		} else {
			_semaphoreArray.signal()
		}
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
		_semaphoreIsAllGifsLoaded.wait()
		if (_isAllGifsLoaded) {
			_semaphoreIsAllGifsLoaded.signal()
			tag = _convertSearchTagToLinkFormat(tag: searchBar.text!)
			searchBar.text! = ""
			_semaphoreArray.wait()
			RandomGifsViewController.gifArray.removeAll(keepingCapacity: true)
			_semaphoreArray.signal()
			_refresh(refreshControlState: false)
			print("Start searching..", searchTag, randomGifAPILink + searchTag + endLink)
		} else {
			_semaphoreIsAllGifsLoaded.signal()
			searchBar.text! = ""
		}
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
