//
//  SingleEntry.swift
//  Rabbit Food
//
//  Created by Christian Raroque on 7/8/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit

class SingleEntry: UIViewController {

    var color = UIColor()
    var entry = "Nothing here yet :)"
    var entryTitle = "No title"
    var key = "none"
    
    var field = ["Gratitude 1", "Gratitude 2", "Gratitude 3", "Positive Experience 1", "Positive Experience 2", "Exercise", "Food", "Meditation", "Random Act of Kindness"]
    var typeKeys = ["grat1", "grat2", "grat3", "post1", "post2", "exercise", "food", "meditation", "raok"]
    
    @IBOutlet weak var entryText: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = colorWithHexString("#ffffff")
        navigationController?.hidesBarsOnSwipe = false
    
        let index = typeKeys.index(of: key)
        self.title = self.field[index!]
        
        self.view.backgroundColor = color
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SingleEntry.popToRoot(_:)))
        
        self.entryText.text = entry
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popToRoot(_ sender:UIBarButtonItem){
        // self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    


}
