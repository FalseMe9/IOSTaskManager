//
//  ShortcutCell.swift
//  IOSTaskManager
//
//  Created by Billie H on 30/07/24.
//

import UIKit

class ShortcutCell: UITableViewCell {

    @IBOutlet var nameL:UILabel!
    var previousView : ShortcutView!
    var indexPath: IndexPath!
    var row : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func closeB(){
        let str = shortcutTitles[row]
        shortcutTitles.remove(at: row)
        shortcutDict[str] = nil
        previousView.shortcutTable.reloadData()
    }
    @IBAction func imgB(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "descriptionViewController") as! DescriptionViewController
        
        let name = shortcutTitles[row]
        newViewController.titleView = name
        newViewController.previousView = previousView!
        previousView.navigationController?.pushViewController(newViewController, animated: true)
    }
}
