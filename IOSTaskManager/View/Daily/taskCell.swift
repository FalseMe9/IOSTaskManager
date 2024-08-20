//
//  taskCell.swift
//  IOSTaskManager
//
//  Created by Billie H on 22/07/24.
//

import UIKit

class taskCell: UITableViewCell {
    
    @IBOutlet var taskL : UILabel!
    @IBOutlet var checkB : UIButton!
    
    var group: Group!
    var index: Int!
    var indexPath: IndexPath!
    var task:Task!
    var previousView:DailyView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .left
        self.addGestureRecognizer(swipe)
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .right
        self.addGestureRecognizer(swipe)
        
        
        
        // Initialization code
    }
    @objc func swipeGesture(swipe: UISwipeGestureRecognizer){
        switch swipe.direction{
        case .left:
            completion()
        case .right:
            didTapMove(self)
        default:
            break
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func didTapCheck(_ sender:Any){
        completion()
    }
    func completion(_ animation: UITableView.RowAnimation = .left, _ warning:Bool=useWarning){
        
        if !warning{
            self.group.taskList.remove(at: self.index)
            if let dailyView = dailyView{
                dailyView.tableView1.deleteRows(at: [self.indexPath], with: animation)
                dailyView.tableView1.reloadData()
            }
            return
        }
        
        let alert = UIAlertController(title: "Reminders", message: "Is This Task Completed?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Finished", style: .destructive, handler: {_ in
            self.group.taskList.remove(at: self.index)
            if let dailyView = dailyView{
                dailyView.tableView1.deleteRows(at: [self.indexPath], with: animation)
                dailyView.tableView1.reloadData()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = previousView.view
            popoverPresentationController.sourceRect = CGRectMake(previousView.view.bounds.size.width / 2.0, previousView.view.bounds.size.height / 2.0, 1.0, 1.0)

        }
        previousView.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapMove(_ sender:Any){
        if let hourlyView = hourlyView{
            hourly.append(task)
            completion(.right, false)
        }
        else{
            let alert = UIAlertController(title: "Warning", message: "Hourly Controller haven't initiated yet", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
                (action) in alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = previousView.view
                popoverPresentationController.sourceRect = CGRectMake(previousView.view.bounds.size.width / 2.0, previousView.view.bounds.size.height / 2.0, 1.0, 1.0)

            }
            previousView.present(alert, animated: true)
        }
        
    }
    
    @IBAction func didTapInfo(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "descriptionViewController") as! DescriptionViewController
        let name = task.name
        newViewController.titleView = name
        newViewController.previousView = previousView
        previousView.navigationController?.pushViewController(newViewController, animated: true)
    }
}
