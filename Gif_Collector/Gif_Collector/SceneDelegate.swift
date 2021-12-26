//
//  SceneDelegate.swift
//  Gif_Collector
//
//  Created by Stepan Kirillov on 12/17/21.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "GifDataModel")
		container.loadPersistentStores(completionHandler: {
			storeDescription, error in
			if let error = error {
				fatalError("Could load data store \(error)")
			}
		})
		return (container)
	}()
	
	lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		self.window = UIWindow(windowScene: windowScene)
		let tabBar = TabBar()
		self.window!.rootViewController = tabBar
		self.window!.makeKeyAndVisible()
		_passManagedObjectContextToViewControllers()
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}
	
	private func _passManagedObjectContextToViewControllers() {
		let tabBarController = window!.rootViewController as! TabBar
		
		if let tabBarViewControllers = tabBarController.viewControllers {
			let currentLocationViewController = tabBarViewControllers[0] as! SavedGifsViewController
			currentLocationViewController.managedObjectContext = managedObjectContext
			
			let controller2 = tabBarViewControllers[1] as! RandomGifsViewController
			controller2.managedObjectContext = managedObjectContext
		}
	}

}

