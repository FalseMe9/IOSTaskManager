//
//  TabViewController.swift
//  IOSTaskManager
//
//  Created by Billie H on 01/08/24.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        var swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .left
        self.view.addGestureRecognizer(swipe)
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "Hourly") as! HourlyView
        hourlyView = newViewController
        hourlyView?.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @objc private func swipeGesture(swipe:UISwipeGestureRecognizer){
        switch swipe.direction{
            
        case .right :
            if selectedIndex > 0{
                self.selectedIndex = self.selectedIndex-1
            }
            break
        case .left :
            if selectedIndex < 4{
                self.selectedIndex = self.selectedIndex+1
            }
            break
        default :
            break
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getIndex(vc : UIViewController)->Int?{
        return viewControllers?.firstIndex(where:{$0.isEqual(vc)})
    }
}

extension TabViewController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        var check = true
        if let fromIndex = getIndex(vc: fromVC), let toIndex = getIndex(vc: toVC){
            check = fromIndex>toIndex
        }
        
        return tabViewAnimation(check)
    }
    
    
    
}

class tabViewAnimation: NSObject, UIViewControllerAnimatedTransitioning{
    var check = true
    init(_ check : Bool){
        self.check = check
    }
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.view(forKey: .to) else{return}
//        
//        destination.transform = CGAffineTransformInvert(CGAffineTransform(translationX: 0, y: destination.frame.height))
        destination.transform = CGAffineTransform(translationX: destination.frame.width, y: 0)
        
        if check{
            destination.transform = CGAffineTransformInvert(destination.transform)
        }
        
        transitionContext.containerView.addSubview(destination)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:{
            destination.transform = .identity
        }, completion: {transitionContext.completeTransition($0)})
    }
}

