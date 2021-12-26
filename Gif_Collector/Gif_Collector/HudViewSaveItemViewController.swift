//
//  HudViewSaveItemViewController.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/25/21.
//

import Foundation
import UIKit

class HudView: UIView {
	
	var text = ""
	var isAnythingToSave = false
	
	private let _hudSize: CGFloat = 96
	
	lazy private var _hudImageConfig = UIImage.SymbolConfiguration(
												pointSize: _hudSize * 0.5,
												weight: .regular,
												scale: .medium)
	
	class func hud(inView view: UIView, animated: Bool) -> HudView {
		let hudView = HudView()
		hudView.frame = view.bounds
		hudView.isOpaque = false
		view.addSubview(hudView)
		view.isUserInteractionEnabled = false
		hudView.show(animated: animated)
		return (hudView)
	}
	
	override func draw(_ rect: CGRect) {
		let boxWidth: CGFloat = _hudSize
		let boxHeight: CGFloat = _hudSize
		
		let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
							 y: round((bounds.size.height - boxHeight) / 2),
							 width: boxWidth,
							 height: boxHeight)
		
		let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
		UIColor { tc in
			switch tc.userInterfaceStyle {
			case .dark:
				return (UIColor(red: 80/256, green: 73/256, blue: 69/256, alpha: 1))
			default:
				return (UIColor(red: 0.945, green: 0.894, blue: 0.734, alpha: 1))
			}
		}.setFill()
		roundedRect.fill()
		
		let tintColor = UIColor { tc in
			switch tc.userInterfaceStyle {
			   case .dark:
				   return (darkThemeTintColor)
			   default:
				   return (lightThemeTintColor)
			}
		}
		
		let imageName: String = {
			switch isAnythingToSave {
			case true:
				return ("checkmark.circle")
			default:
				return ("star.slash.fill")
			}
		}()
		
		if let image = UIImage(systemName: imageName, withConfiguration: _hudImageConfig) {
			let imageWithColor = image.withTintColor(tintColor)
			let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
									 y: center.y - round(image.size.height / 2) - boxHeight / 8)
			imageWithColor.draw(at: imagePoint)
		}
		
		let attribs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
					   NSAttributedString.Key.foregroundColor: tintColor]
		let textSize = text.size(withAttributes: attribs)
		
		let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
								y: center.y - round(textSize.height / 2) + boxHeight / 4)
		text.draw(at: textPoint, withAttributes: attribs)
	}
	
	func show(animated: Bool) {
		if (animated) {
			alpha = 0
			transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			
			UIView.animate(withDuration: 			0.3,
						   delay: 					0,
						   usingSpringWithDamping:	1,
						   initialSpringVelocity: 	1,
						   options: 				[],
						   animations: {
								[weak self] in
			
								self?.alpha = 1
								self?.transform = CGAffineTransform.identity
						   },
						   completion: 				nil)
		}
	}
	
}

