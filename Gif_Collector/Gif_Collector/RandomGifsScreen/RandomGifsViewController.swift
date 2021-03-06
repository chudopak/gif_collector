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
	
	static private var _gifArray = [RowGifsData]()
	static private var _isFirstLoad = true
	static private var _gifArraySize = 0
	
	private let _semaphoreArray = DispatchSemaphore(value: 1)
	private let _semaphoreThreads = DispatchSemaphore(value: 2)
	private let _semaphoreIsAllGifsLoaded = DispatchSemaphore(value: 1)
	
	private var _isAllGifsLoaded = true
	
	private let _parse = ParseJSON()
	
	private var _searchTag = ""
	private var _tag = ""
	
	private lazy var _refreshToPull: UIRefreshControl = {
		var refreshControll = UIRefreshControl()
		refreshControll.addTarget(self, action: #selector(_refreshControllerCalled), for: .valueChanged)
		return (refreshControll)
	} ()
	
	private lazy var _refreshButton: UIButton = {
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

	private lazy var _topBarView: UIView = {
		let v = UIView()
		v.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topBarHeight)
		return (v)
	}()
	
	private lazy var _searchBar: UISearchBar = {
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
	
	init(managedObj: NSManagedObjectContext) {
		managedObjectContext = managedObj
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_setTableView()
		_setTopBarView()
		if (RandomGifsViewController._isFirstLoad) {
			_semaphoreArray.wait()
			RandomGifsViewController._gifArray.reserveCapacity(50)
			RandomGifsViewController._isFirstLoad = false
			_semaphoreArray.signal()
			_refresh(refreshControlState: false)
			_semaphoreArray.wait()
			RandomGifsViewController._gifArraySize = RandomGifsViewController._gifArray.count
			_semaphoreArray.signal()
		}
	}
	
	private func _setTopBarView() {
		view.addSubview(_topBarView)
		_topBarView.addSubview(_searchBar)
		_topBarView.addSubview(_refreshButton)
		_searchBar.delegate = self
		if let textField = _searchBar.value(forKey: "searchField") as? UITextField {
			textField.backgroundColor = UIColor { tc in
				switch tc.userInterfaceStyle {
				case .dark:
					return (UIColor(red: 0.19, green: 0.195, blue: 0.199, alpha: 1))
				default:
					return (UIColor(red: 0.945, green: 0.894, blue: 0.734, alpha: 1))
				}
			}
		}
		_searchBar.frame = CGRect(x: 0,
								 y: 0,
								 width: UIScreen.main.bounds.width - topBarHeight,
								 height: topBarHeight)
		_refreshButton.frame = CGRect(x: UIScreen.main.bounds.width - topBarHeight,
									 y: 0,
									 width: topBarHeight,
									 height: topBarHeight)
	}
	
	private func _setTableView() {
		tableView.refreshControl = _refreshToPull
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
		_refreshToPull.endRefreshing()
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
				if (RandomGifsViewController._gifArray.count >= 10 || numberOfChecks >= 60) {
					self._semaphoreArray.signal()
					DispatchQueue.main.async {
						if (refeshControlState) {
							self._refreshToPull.endRefreshing()
						}
						self._refreshButton.isEnabled = true
						
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
		RandomGifsViewController._gifArray.removeAll(keepingCapacity: true)
		_semaphoreArray.signal()
		_searchBar.resignFirstResponder()
		_searchBar.showsCancelButton = false
		_refreshButton.isEnabled = false
		_searchTag = _tag
		_tag = ""
		_observer(refeshControlState: refreshControlState)
		_loadFirstGifs()
	}

	private func _loadFirstGifs() {
		DispatchQueue.global(qos: .userInitiated).async {
			for _ in 0..<10 {
				self._semaphoreThreads.wait()
				DispatchQueue.global(qos: .userInitiated).async {
					guard let leftGifData = self._parse.getGifData(searchURL: randomGifAPILink + self._searchTag + endLink) else {
						print("Left gif doesn't load")
						return
					}
					guard let rightGifData = self._parse.getGifData(searchURL: randomGifAPILink + self._searchTag + endLink) else {
						print("right gif doesn't load")
						return
					}

					let rowGifs = RowGifsData(leftGif: leftGifData, rightGif: rightGifData)
					
					self._semaphoreArray.wait()
					RandomGifsViewController._gifArray.append(rowGifs)
					self._semaphoreArray.signal()

					self._semaphoreArray.wait()
					RandomGifsViewController._gifArraySize = RandomGifsViewController._gifArray.count
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
		
		if (RandomGifsViewController._gifArraySize < 8) {
			return (4)
		}
		return (RandomGifsViewController._gifArraySize)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GifTableViewCell", for: indexPath) as! GifTableViewCell
		
		var gifs: RowGifsData?
		var topBarOffset: CGFloat = 0
		if (indexPath.row == 0) {
			topBarOffset = _topBarView.bounds.size.height
		}
		cell.selectionStyle = .none

		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController._gifArray.count) {
			gifs = RandomGifsViewController._gifArray[indexPath.row]
		}
		_semaphoreArray.signal()

		cell.configureGifs(gifs: gifs, topBarOffset: topBarOffset)
		return (cell)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var cellHeight: CGFloat = -1
		var searchBarOffset: CGFloat = 0
		if (indexPath.row == 0) {
			searchBarOffset = _topBarView.bounds.size.height
		}
		_semaphoreArray.wait()
		if (indexPath.row < RandomGifsViewController._gifArray.count) {
			cellHeight = RandomGifsViewController._gifArray[indexPath.row].cellHeight
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
		if (indexPath.row < RandomGifsViewController._gifArray.count) {
			let gifs = RandomGifsViewController._gifArray[indexPath.row]
			_semaphoreArray.signal()
			let saveItemViewController = SaveItemViewController()
			
			saveItemViewController.managedObjectContext = managedObjectContext

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
			_tag = _convertSearchTagToLinkFormat(tag: searchBar.text!)
			searchBar.text! = ""
			_semaphoreArray.wait()
			RandomGifsViewController._gifArray.removeAll(keepingCapacity: true)
			_semaphoreArray.signal()
			_refresh(refreshControlState: false)
			print("Start searching..", _searchTag, randomGifAPILink + _searchTag + endLink)
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
