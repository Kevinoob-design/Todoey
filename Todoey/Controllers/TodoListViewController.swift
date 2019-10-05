//
//  ViewController.swift
//  Todoey
//
//  Created by Hector Morales veloz on 9/26/19.
//  Copyright © 2019 Hector Morales veloz. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        didSet{
            LoadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        guard let colourHex = selectedCategory?.colour else{fatalError()}
        
        title = selectedCategory?.name
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "FEFEFE")
        
    }
    
    //MARK: - Navbar Setup Methods
    func updateNavBar(withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else{fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode)else{fatalError()}
                
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)
        
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.tittle
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
            }
                
            cell.accessoryType = item.done == true ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: Add New Items
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                                
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.tittle = textField.text!
                        newItem.dateCreated = Date.init()
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Model Manipulation Methods
    
    func LoadItems(){
            
        todoItems = selectedCategory?.items.sorted(byKeyPath: "tittle", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: Delete method for Swipe
    override func updateModel(at indexPath: IndexPath) {

        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }
            catch{
                print("Error saving context, \(error)")
            }
        }
    }
}

//MARK: Extension for UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            LoadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else{
            todoItems = todoItems?.filter("tittle CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
            
            tableView.reloadData()
        }
    }
}
