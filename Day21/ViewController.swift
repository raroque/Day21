//
//  ViewController.swift
//  Rabbit Food
//
//  Created by Christian Raroque on 7/5/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rabbitTable: UITableView!
    @IBOutlet weak var completeMessage: UIImageView!
    
    var field = ["Gratitude 1", "Gratitude 2", "Gratitude 3", "Positive Experience 1", "Positive Experience 2", "Exercise", "Food", "Meditation", "Random Act of Kindness"]
    var placeHolders = ["What are you grateful for?", "What are you grateful for?", "What are you grateful for?", "What is a positive experience you had today?", "What is a positive experience you had today?", "What exercise did you do today?", "How was your diet today, what did you eat?", "What form of meditation did you do today?", "What was your random act of kindness"]
    
    // typeKeys are the keys coredata will use
    var typeKeys = ["grat1", "grat2", "grat3", "post1", "post2", "exercise", "food", "meditation", "raok"]
    var previousEntries = ["","","","","","","","",""]
    var colors = [UIColor]()
    var textColors = [UIColor]()
    
    // A boolean to determine whether or not to mark the field as completed
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
    
    // Although loaded above, you can make custom instances of this function to change the fields that appear in the app
    
    func loadFields() {
        field = ["Gratitude 1", "Gratitude 2", "Gratitude 3", "Positive Experience 1", "Positive Experience 2", "Exercise", "Food", "Meditation", "Random Act of Kindness"]
        placeHolders = ["What are you grateful for?", "What are you grateful for?", "What are you grateful for?", "What is a positive experience you had today?", "What is a positive experience you had today?", "What exercise did you do today?", "How was your diet today, what did you eat?", "What form of meditation did you do today?", "What was your random act of kindness"]
        typeKeys = ["grat1", "grat2", "grat3", "post1", "post2", "exercise", "food", "meditation", "raok"]
        previousEntries = ["","","","","","","","",""]
        colors = [UIColor]()
        textColors = [UIColor]()
        strikeThroughValues = [Bool]()
    }
    
    // Sort through the existing core data and see if any entries have already been
    // made for the day
    
    func sortData() {
        // The day today (start of the day)
        let today = Date()
        let cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let startOfDay = cal!.startOfDay(for: today)

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
            if(results.count != 0) {
                NSLog("the results is not 0")
                let lastDay = results[0]
                
                if let dateOfLastEntry = (lastDay as AnyObject).value(forKey: "date") as? NSDate {
                    // Check if there is an entry
                    NSLog("date of lastEntry is \(dateOfLastEntry) and start of day is \(startOfDay)")
                    if(dateOfLastEntry as Date == startOfDay) {
                        NSLog("something exists")
                        // Something already exists, so update it instead of creating a new entry
                        let day = lastDay
                        let attributes = (day as AnyObject).entity.attributesByName
                        for (key, value) in attributes {
                            if let value = (day as AnyObject).value(forKey: key) as? NSString {
                                
                                // Index of the typekey (used as the main key that the other arrays follow)
                                let index = typeKeys.index(of: key)
                                if(index != nil) {
                                    // Since the index is not null, that means a typeKey exists in coredata for this day. That means this field has been filled out and we can cross it out
                                    
                                    self.colors[index!] = colorWithHexString("#ffffff")
                                    self.textColors[index!] = colorWithHexString("#000000")
                                    self.strikeThroughValues[index!] = true
                                    self.previousEntries[index!] = value as String
                                    
                                    self.field.insert(self.field.remove(at: index!), at: self.field.count)
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
        for _ in field {
            // This loads it as a...gradient...I think that's the word...probably not
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
        return  self.field.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newEntry = self.storyboard!.instantiateViewController(withIdentifier: "newEntry") as! NewEntry
        if(self.strikeThroughValues[(indexPath as NSIndexPath).row]) {
            newEntry.hexmain = colorWithHexString("#02C39A")
            newEntry.previousEntry = previousEntries[(indexPath as NSIndexPath).row]
        } else {
            newEntry.hexmain = self.colors[(indexPath as NSIndexPath).row]
        }
        
        newEntry.type = self.field[(indexPath as NSIndexPath).row]
        newEntry.typeKey = self.typeKeys[(indexPath as NSIndexPath).row]
        newEntry.placeHolderText = self.placeHolders[(indexPath as NSIndexPath).row]
        
        //self.presentViewController(newEntry, animated: true, completion: nil)
       // self.navigationController?.presentViewController(newEntry, animated: true, completion: nil)
        self.navigationController?.pushViewController(newEntry, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        let item = self.field[(indexPath as NSIndexPath).row]
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
        
        return cell
    }
    
    func checkIfClear() {
        // Check if they are all clear, if they are then show the completed message
        var allClear = true
        
        for strike in self.strikeThroughValues {
            if(!strike) {
                allClear = false
            }
        }
        
        if(allClear) {
            rabbitTable.beginUpdates()
            
            let fieldCount = self.field.count
            for i in stride(from: fieldCount - 1,to: 0, by: -1) {
            
                self.rabbitTable.deleteRows(at: [IndexPath(row: i, section: 0)], with: UITableViewRowAnimation.fade)
                self.colors.remove(at: i)
                self.textColors.remove(at: i)
                self.field.remove(at: i)
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

