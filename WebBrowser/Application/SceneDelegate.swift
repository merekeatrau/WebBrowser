//
//  SceneDelegate.swift
//  WebBrowser
//
//  Created by Mereke on 07.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let leftVС = ViewController()
        let leftNavController = UINavigationController(rootViewController: leftVС)

        let rightVC = WebViewController(delegate: leftVС)
        let rightNavController = UINavigationController(rootViewController: rightVC)

        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [leftNavController, rightNavController]
        splitViewController.preferredDisplayMode = .oneBesideSecondary

        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
    }
}

