//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hector Morales veloz on 10/1/19.
//  Copyright © 2019 Hector Morales veloz. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet."
        
        return cell
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func Save(category: Category) -> Void {
                
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
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
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

//MARK: Extension for UISearchBarDelegate
//extension CategoryViewController: UISearchBarDelegate{
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0{
//            LoadCategory()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//        else{
//            let request: NSFetchRequest<Category> = Category.fetchRequest()
//
//            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
//            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//
//            LoadCategory(with: request)
//        }
//    }
//}
