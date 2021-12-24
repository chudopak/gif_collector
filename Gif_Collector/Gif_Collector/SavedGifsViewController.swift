//
//  SavedGifsViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/24/21.
//

import UIKit


class SavedGifTableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		contentView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
	
	static let identifier = "GifCell"
}


extension SavedGifsViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		10
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SavedGifTableViewCell.identifier, for: indexPath) as! SavedGifTableViewCell
		cell.textLabel?.text = "boba"
		
		return (cell)
	}
	
	
}

class SavedGifsViewController: UIViewController {

	let tableView = UITableView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.113, green: 0.125, blue: 0.129, alpha: 1))
			default:
				return (UIColor(red: 0.984, green: 0.941, blue: 0.778, alpha: 1))
			}
		}
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(SavedGifTableViewCell.self, forCellReuseIdentifier: SavedGifTableViewCell.identifier)
		view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
