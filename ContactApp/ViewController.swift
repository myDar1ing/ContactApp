//
//  ViewController.swift
//  ContactApp
//
//  Created by Adilet Kenesbekov on 18.10.2024.
//

import UIKit

protocol ContactDelegate : AnyObject{
    func didAddContact(_ contact : Contact)
}

class TableViewController: UITableViewController {
    var contacts : [Contact] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
    }
    //creates a cell,gives the opportunity to populate them
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        //cell.detailTextLabel?.text = contact.phoneNumber
        return cell
    }
    //defines how many rows or cells will we have
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? ContactEntryVIewController {
                destination.delegate = self
            }
        }
    
}

extension TableViewController : ContactDelegate {
    func didAddContact(_ contact: Contact) {
        contacts.append(contact)
        tableView.reloadData()
    }
}

class ContactEntryVIewController : UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBAction func SaveBut(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let number = numberTextField.text, !number.isEmpty else {
            showAlert(message: "Name and Phone Number are required.")
            return
        }

        let surname = surnameTextField.text ?? ""  // Default to empty string if nil
            let company = companyTextField.text ?? ""
            let email = emailTextField.text ?? ""

            // Create a new contact with optional fields
            let newContact = Contact(
                name: name,
                surname: surname,
                company: company,
                phoneNumber: number,
                email: email
            )

            // Notify the delegate and dismiss the view
            delegate?.didAddContact(newContact)
            //dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
    }
    weak var delegate: ContactDelegate?
    
//    @IBAction func saveButton(_ sender: UIBarButtonItem) {
//        guard let name = nameTextField.text, !name.isEmpty,
//              let number = numberTextField.text, !number.isEmpty else {
//            showAlert(message: "Name and Phone Number are required.")
//            return
//        }
//
//        let surname = surnameTextField.text ?? ""  // Default to empty string if nil
//            let company = companyTextField.text ?? ""
//            let email = emailTextField.text ?? ""
//
//            // Create a new contact with optional fields
//            let newContact = Contact(
//                name: name,
//                surname: surname,
//                company: company,
//                phoneNumber: number,
//                email: email
//            )
//
//            // Notify the delegate and dismiss the view
//            delegate?.didAddContact(newContact)
//            //dismiss(animated: true, completion: nil)
//            navigationController?.popViewController(animated: true)
//    }
    
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
