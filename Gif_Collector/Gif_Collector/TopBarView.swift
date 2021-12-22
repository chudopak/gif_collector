//
//  TopBarView.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/22/21.
//

import UIKit

class TopBarView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		backgroundColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1))
			default:
				return (UIColor(red: 0.91, green: 0.941, blue: 0.73, alpha: 1))
			}
		}
	}
	
}
