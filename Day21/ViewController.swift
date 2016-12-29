//
//  ViewController.swift
//  Rabbit Food
//
//  Created by Chris on 7/5/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rabbitTable: UITableView!
    @IBOutlet weak var completeMessage: UIImageView!
    
    var food = ["Gratitude 1", "Gratitude 2", "Gratitude 3", "Positive Experience 1", "Positive Experience 2", "Exercise", "Food", "Meditation", "Random Act of Kindness"]
    var placeHolders = ["What are you grateful for?", "What are you grateful for?", "What are you grateful for?", "What is a positive experience you had today?", "What is a positive experience you had today?", "What exercise did you do today?", "How was your diet today, what did you eat?", "What form of meditation did you do today?", "What was your random act of kindness"]
    var typeKeys = ["grat1", "grat2", "grat3", "post1", "post2", "exercise", "food", "meditation", "raok"]
    var previousEntries = ["","","","","","","","",""]
    var colors = [UIColor]()
    var textColors = [UIColor]()
    var strikeThroughValues = [Bool]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        loadFields()
        loadColors()
        sortData()
        checkIfClear()
        
        self.rabbitTable.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        rabbitTable.delegate = self
        rabbitTable.dataSource = self
        completeMessage.isHidden = true
        rabbitTable.isHidden = false
        
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeLeft(_:)))
        recognizer.direction = .left
        self.view .addGestureRecognizer(recognizer)
    }
    
    func loadFields() {
        food = ["Gratitude 1", "Gratitude 2", "Gratitude 3", "Positive Experience 1", "Positive Experience 2", "Exercise", "Food", "Meditation", "Random Act of Kindness"]
        placeHolders = ["What are you grateful for?", "What are you grateful for?", "What are you grateful for?", "What is a positive experience you had today?", "What is a positive experience you had today?", "What exercise did you do today?", "How was your diet today, what did you eat?", "What form of meditation did you do today?", "What was your random act of kindness"]
        typeKeys = ["grat1", "grat2", "grat3", "post1", "post2", "exercise", "food", "meditation", "raok"]
        previousEntries = ["","","","","","","","",""]
        colors = [UIColor]()
        textColors = [UIColor]()
        strikeThroughValues = [Bool]()
    }
    
    func sortData() {
        NSLog("sort data is called")
        // The day today (start of the day)
        var today = Date()
        var cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let startOfDay = cal!.startOfDay(for: today)

        // Done posting
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Pull the last entry
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        var error: NSError?
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            if(results.count != 0) {
                NSLog("the results is not 0")
                let lastDay = results[0]
                //   managedContext.deleteObject(lastDay as NSManagedObject)
                //   managedContext.save(nil)
                
                if let dateOfLastEntry = (lastDay as AnyObject).value(forKey: "date") as? NSDate {
                    // Check if there is an entry
                    NSLog("date of lastEntry is \(dateOfLastEntry) and start of day is \(startOfDay)")
                    if(dateOfLastEntry as Date == startOfDay) {
                        NSLog("something exists")
                        // Something already exists, so update it instead of creating a new entry
                        let day = lastDay
                        var attributes = (day as AnyObject).entity.attributesByName
                        for (key, value) in attributes {
                            if let value = (day as AnyObject).value(forKey: key) as? NSString {
                                var index = typeKeys.index(of: key)
                                if(index != nil) {
                                    
                                    NSLog("something was crossed out \(value)")
                                    
                                    self.colors[index!] = colorWithHexString("#ffffff")
                                    self.textColors[index!] = colorWithHexString("#000000")
                                    self.strikeThroughValues[index!] = true
                                    self.previousEntries[index!] = value as String
                                    
                                    self.food.insert(self.food.remove(at: index!), at: self.food.count)
                                    self.colors.insert(self.colors.remove(at: index!), at: self.colors.count)
                                    self.textColors.insert(self.textColors.remove(at: index!), at: self.textColors.count)
                                    self.strikeThroughValues.insert(self.strikeThroughValues.remove(at: index!), at: self.strikeThroughValues.count)
                                    self.placeHolders.insert(self.placeHolders.remove(at: index!), at: self.placeHolders.count)
                                    self.typeKeys.insert(self.typeKeys.remove(at: index!), at: self.typeKeys.count)
                                    self.previousEntries.insert(self.previousEntries.remove(at: index!), at: self.previousEntries.count)
                                    
                                    self.rabbitTable.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func swipeLeft(_ recognizer : UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "showCal", sender: self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func loadColors() {
        self.colors.removeAll(keepingCapacity: false)
        let colorGenerator = ColorGenerator(hue: 0.5, saturation: 0.8, brightness: 0.9, alpha: 1.0, increment: 0.04)
        for _ in food {
            self.colors.append(colorGenerator.next()!)
            
            self.strikeThroughValues.append(false)
            self.textColors.append(colorWithHexString("#ffffff"))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return  self.food.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newEntry = self.storyboard!.instantiateViewController(withIdentifier: "newEntry") as! NewEntry
        if(self.strikeThroughValues[(indexPath as NSIndexPath).row]) {
            newEntry.hexmain = colorWithHexString("#02C39A")
            newEntry.previousEntry = previousEntries[(indexPath as NSIndexPath).row]
        } else {
            newEntry.hexmain = self.colors[(indexPath as NSIndexPath).row]
        }
        
        newEntry.type = self.food[(indexPath as NSIndexPath).row]
        newEntry.typeKey = self.typeKeys[(indexPath as NSIndexPath).row]
        newEntry.placeHolderText = self.placeHolders[(indexPath as NSIndexPath).row]
        
        //self.presentViewController(newEntry, animated: true, completion: nil)
       // self.navigationController?.presentViewController(newEntry, animated: true, completion: nil)
        self.navigationController?.pushViewController(newEntry, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        let item = self.food[(indexPath as NSIndexPath).row]
        cell.backgroundColor = colors[(indexPath as NSIndexPath).row]
        
        var strike = 0
        
        if(self.strikeThroughValues[(indexPath as NSIndexPath).row]) {
            strike = NSUnderlineStyle.styleSingle.rawValue
        }
        
        let attributes = [
            NSFontAttributeName : UIFont(name: "Avenir", size: 19)!,
            NSForegroundColorAttributeName : textColors[(indexPath as NSIndexPath).row],
            NSStrikethroughStyleAttributeName: strike] as [String : Any]
        
        cell.food.attributedText = NSAttributedString(string: "\(item)", attributes: attributes)
        
      //  var longHold: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "completeTask:")
      //  cell.addGestureRecognizer(longHold)
        
        return cell
    }
    

    /*
    func completeTask(sender: AnyObject) {
        
        if sender.state == UIGestureRecognizerState.Began {
            let cell = sender.view as! MainCell
            let indexPath = (self.rabbitTable as UITableView).indexPathForCell(cell)!
            
            if(!self.strikeThroughValues[indexPath.row]) {
                self.colors[indexPath.row] = colorWithHexString("#ffffff")
                self.textColors[indexPath.row] = colorWithHexString("#000000")
                self.strikeThroughValues[indexPath.row] = true
                
                self.colors.insert(self.colors.removeAtIndex(indexPath.row), atIndex: self.colors.count)
                self.textColors.insert(self.textColors.removeAtIndex(indexPath.row), atIndex: self.textColors.count)
                self.strikeThroughValues.insert(self.strikeThroughValues.removeAtIndex(indexPath.row), atIndex: self.strikeThroughValues.count)
                self.placeHolders.insert(self.placeHolders.removeAtIndex(indexPath.row), atIndex: self.placeHolders.count)
                self.typeKeys.insert(self.typeKeys.removeAtIndex(indexPath.row), atIndex: self.typeKeys.count)
                self.rabbitTable.reloadData()
                
                rabbitTable.beginUpdates()
                
                
                rabbitTable.moveRowAtIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: self.food.count - 1, inSection: 0))
                self.food.insert(self.food.removeAtIndex(indexPath.row), atIndex: self.food.count)
                
                rabbitTable.endUpdates()
                checkIfClear()
            }
            
        }
    } */
    
    func checkIfClear() {
        // Check if they are all clear
        var allClear = true
        
        for strike in self.strikeThroughValues {
            if(!strike) {
                allClear = false
            }
        }
        
        if(allClear) {
            rabbitTable.beginUpdates()
            
            let foodCount = self.food.count
            for i in stride(from: foodCount - 1,to: 0, by: -1) {
            
                self.rabbitTable.deleteRows(at: [IndexPath(row: i, section: 0)], with: UITableViewRowAnimation.fade)
                self.colors.remove(at: i)
                self.textColors.remove(at: i)
                self.food.remove(at: i)
                self.placeHolders.remove(at: i)
                self.typeKeys.remove(at: i)
                self.previousEntries.remove(at: i)
                self.strikeThroughValues.remove(at: i)
            }
            
            rabbitTable.endUpdates()
            
            self.rabbitTable.isHidden = true
            self.completeMessage.isHidden = false
        }
    }
    
}

