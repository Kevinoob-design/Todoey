//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hector Morales veloz on 10/1/19.
//  Copyright © 2019 Hector Morales veloz. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadCategory()
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet."
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].colour ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: cell.backgroundColor ?? UIColor.white, returnFlat: true)
        
        return cell
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func Save(category: Category){
                
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch{
            print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func LoadCategory(){

        categoryArray = realm.objects(Category.self)

        tableView.reloadData()
    }
        
    //MARK: Delete method for swipe
    override func updateModel(at indexPath: IndexPath) {

        if let itemForDeletion = self.categoryArray?[indexPath.row]{
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
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = RandomFlatColor().hexValue()
            
            self.Save(category: newCategory)
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Create new item"
            textField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
}

//MARK: Extension for Swipe Table View Cell Methods
//extension CategoryViewController: SwipeTableViewCellDelegate{
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//
//        guard orientation == .right else { return nil }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//
//            if let categoryForDeletion = self.categoryArray?[indexPath.row]{
//                do{
//                    try self.realm.write {
//                        self.realm.delete(categoryForDeletion)
//                    }
//                }
//                catch{
//                    print("Error saving context, \(error)")
//                }
//            }
//        }
//
//        deleteAction.image = UIImage(systemName: "trash.fill")
//
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        return options
//    }
//}

//MARK: Extension for UISearchBarDelegate
extension CategoryViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            LoadCategory()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else{
            categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
            
            tableView.reloadData()
        }
    }
}
