//
//  SingleDay.swift
//  Rabbit Food
//
//  Created by Christian Raroque on 7/8/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit
import CoreData

class SingleDay: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var entryTable: UITableView!

    var dayObject: NSManagedObject?
    var entries = ["No entries today :("]
    var keys = [String]()
    var colors = [UIColor]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        entryTable.delegate = self
        entryTable.dataSource = self
        
        loadData()
        loadColors()
        
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SingleDay.swipeRight(_:)))
        recognizer.direction = .right
        self.view .addGestureRecognizer(recognizer)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) throws {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            // remove the deleted item from the model
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            var attributes = dayObject!.entity.attributesByName
            dayObject!.setValue(nil, forKey: "\(self.keys[(indexPath as NSIndexPath).row])")
            self.entries.remove(at: (indexPath as NSIndexPath).row)
            self.keys.remove(at: (indexPath as NSIndexPath).row)
            self.colors.remove(at: (indexPath as NSIndexPath).row)
            
            self.entryTable.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            try context.save()
        }
    }
    
    func swipeRight(_ recognizer : UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func loadData() {
        self.entries.removeAll(keepingCapacity: false)
        let attributes = dayObject!.entity.attributesByName
        for (key, value) in attributes {
            if let value = dayObject!.value(forKey: key ) as? NSString {
                self.keys.append(key )
                self.entries.append(value as String)
            }
        }
    }
    
    func loadColors() {
        self.colors.removeAll(keepingCapacity: false)
        let colorGenerator = ColorGenerator(hue: 0.5, saturation: 0.8, brightness: 0.9, alpha: 1.0, increment: 0.04)
        for item in entries {
            self.colors.append(colorGenerator.next()!)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return  self.entries.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let moreDetail = self.storyboard!.instantiateViewController(withIdentifier: "singleEntry") as! SingleEntry
        
        moreDetail.entry = "\(self.entries[(indexPath as NSIndexPath).row])"
        moreDetail.color = self.colors[(indexPath as NSIndexPath).row]
        moreDetail.key = "\(self.keys[(indexPath as NSIndexPath).row])"
        
        //self.presentViewController(newEntry, animated: true, completion: nil)
        // self.navigationController?.presentViewController(newEntry, animated: true, completion: nil)
        self.navigationController?.pushViewController(moreDetail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        let item = self.entries[(indexPath as NSIndexPath).row]
        cell.backgroundColor = colors[(indexPath as NSIndexPath).row]
        
        cell.food.text = "\(item)"
        
        return cell
    }
    
}
