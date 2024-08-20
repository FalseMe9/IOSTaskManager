//
//  HourlyTableCell.swift
//  IOSTaskManager
//
//  Created by Billie H on 11/08/24.
//

import UIKit

class HourlyTableCell: UITableViewCell {

    
    @IBOutlet var name: UILabel!
    @IBOutlet var playB: UIButton!
    
    var previousView: HourlyView2!
    var row = 0
    var timer = Timer()
    var task : Task!
    var indexPath:IndexPath!
    var isPlaying = false {
        didSet{
            if isPlaying{
                playB.setImage(.pauseButtonSvgrepoCom, for: .normal)
                previousView.isPlaying = true
                print(row)
            }
            else{
                playB.setImage(.playButtonSvgrepoCom1, for: .normal)
                previousView.isPlaying = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if row == hourly.count{
            task = breaks
        }
        else{
            task = hourly[row]
        }
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
    
    @IBAction func playB(_ sender:Any){
        print(isPlaying)
        if previousView.viewIfLoaded?.window == nil{
            return
        }
        hourlyView?.row = row
        hourlyView?.start(self)
    }
    
    @IBAction func closeB(_ sender:Any){
        hourly.remove(at: row)
        previousView.taskTable.reloadData()
        if isPlaying{
            isPlaying = false
        }
        if previousView.isPlayingAll{
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction2), userInfo: nil, repeats: false)
        }
    }
    @objc func timerAction2(){
        previousView.playAllB(self)
    }
    
    
    @objc func swipeGesture(swipe: UISwipeGestureRecognizer){
        if task.name.myHash() == breaks.name.myHash(){
            return
        }
        switch swipe.direction{
        case .left:
            completion()
        case .right:
            completion()
        default:
            break
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func completion(_ animation: UITableView.RowAnimation = .left, _ warning:Bool=useWarning){
        
        if !warning{
            delete(animation)
            return
        }
        
        let alert = UIAlertController(title: "Reminders", message: "Is This Task Completed?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Finished", style: .destructive, handler: {_ in
            self.delete(animation)
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
    func delete(_ animation: UITableView.RowAnimation = .left){
        if isPlaying{
            hourlyView?.finish(self)
        }
        else{
            print(row)
            print(hourly.count)
            hourly.remove(at: self.row)
            if row < hourlyView?.row ?? 0{
                hourlyView?.row -= 1
            }
//            previousView.taskTable.deleteRows(at: [self.indexPath], with: animation)
        }
        previousView.taskTable.reloadData()
        
        return
    }

    @IBAction func didTapNext(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "descriptionViewController") as! DescriptionViewController
        let name = task.name
        newViewController.titleView = name
        newViewController.previousView = dailyView
        previousView.navigationController?.pushViewController(newViewController, animated: true)
    }
}
