//
//  AppDelegate.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var rootNavController:UINavigationController?
    
    private var welcomeController:WelcomeViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        
        rootNavController = UINavigationController()
        welcomeController = WelcomeViewController()
        rootNavController!.viewControllers = [welcomeController!]
        rootNavController!.delegate = self
        
        window?.rootViewController = rootNavController!
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        NotificationCenter.default.removeObserver(self)
        NetworkStateListener.default.stopListening()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.customAddObserver(self, selector: #selector(onNetworkStateChange), name: .NetworkStateChanged, object: nil)
        NetworkStateListener.default.startListening()
    }


}

extension AppDelegate{
    @objc private func onNetworkStateChange(){
        guard Server.instance.connectMode == .Lan else { return }
        if NetworkStateListener.default.connection != .wifi{
            if self.rootNavController!.topViewController != welcomeController! {
                ZxHUD.shared.display(type: .Error, title: "网络连接错误", duration: 2)
                self.rootNavController?.popToViewController(welcomeController!, animated: true)
            }
        }
    }
}


extension AppDelegate:UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is WordsTransController && toVC is WordsTransController{
            return BackWordsAnimateTransition(operation: operation)
        }
        else if fromVC is WelcomeViewController || toVC is WelcomeViewController {
            return PureColorAnimateTransition(color: .black)
        }
        else if fromVC is WordsTransController && toVC is GameBaseController{
            return PureColorAnimateTransition(color: .black)
        }
        else if fromVC is GameBaseController && toVC is WordsTransController {
            return PureColorAnimateTransition(color: .black)
        }
        return nil
    }
    
    
}
