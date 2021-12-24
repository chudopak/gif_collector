//
//  TabBar.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/24/21.
//

import UIKit

class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		UITabBar.appearance().barTintColor = .systemBackground
		tabBar.tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.976, green: 0.738, blue: 0.184, alpha: 1))
			default:
				return (UIColor(red: 0.347, green: 0.16, blue: 0.367, alpha: 1))
			}
		}
		tabBar.barTintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
				case .dark:
					return (UIColor(red: 0.19, green: 0.195, blue: 0.199, alpha: 1))
				default:
					return (UIColor(red: 0.945, green: 0.894, blue: 0.734, alpha: 1))
			}
		}
		setupViewControllers()

        // Do any additional setup after loading the view.
    }
	
	func setupViewControllers() {
		
		let randomGifsVC = RandomGifsViewController()
		let savedGifsVC = SavedGifsViewController()
		
		randomGifsVC.title = NSLocalizedString("Explore", comment: "")
		savedGifsVC.title = NSLocalizedString("Saves", comment: "")
		
		setViewControllers([savedGifsVC, randomGifsVC], animated: false)
		
		guard let items = tabBar.items else {
			print("Can't get items from tabBar")
			return
		}
		
//		let searchConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
		
		items[0].image = UIImage(systemName: "star")
		items[1].image = UIImage(systemName: "magnifyingglass.circle")
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
