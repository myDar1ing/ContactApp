//  ViewController.swift
//  ContactApp
//
//  Created by Adilet Kenesbekov on 18.10.2024.
import UIKit

protocol ContactDelegate : AnyObject{
    func didAddContact(_ contact : Contact)
    func didUpdateContact(_ contact : Contact, at index : Int)
}

class TableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var contacts : [Contact] = []
    var filteredContacts : [Contact] = []
    var isSearching : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        loadContacts()
        searchBar.delegate = self
    }
    //bonus:searchbar logic
    func searchBar(_ searchBar : UISearchBar, textDidChange searchtext: String) {
        if searchtext.isEmpty {
            isSearching = false
            filteredContacts.removeAll()
        } else {
            isSearching = true
            filteredContacts = contacts.filter { contact in
                return contact.name.lowercased().contains(searchtext.lowercased())
            }
        }
        tableView.reloadData()
    }
    func saveContacts() {
        if let encodedData = try? JSONEncoder().encode(contacts){
            UserDefaults.standard.set(encodedData, forKey: "SavedContacts")
        }
    }
    func loadContacts() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedContacts"),
           let decodedContacts = try? JSONDecoder().decode([Contact].self, from: savedData){
            contacts = decodedContacts
        }
    }
    //creates a cell,gives the opportunity to populate them
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = isSearching ? filteredContacts[indexPath.row] : contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        return cell
    }
    //defines number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredContacts.count : contacts.count
    }
    //segue logic for editing a contact
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row]
        performSegue(withIdentifier: "EditContactSegue", sender: (selectedContact, indexPath.row))
    }
    //navigation setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? ContactEntryVIewController {
                if let (contact, index) = sender as? (Contact, Int) {
                    destination.contact = contact
                    destination.contactIndex = index
                    destination.isEditMode = true
                } else {
                    destination.isEditMode = false
                }
                destination.delegate = self
            }
        }
}

extension TableViewController : ContactDelegate {
    func didAddContact(_ contact: Contact) {
        contacts.append(contact) //add new contact
        tableView.reloadData() //refresh main page
        saveContacts() //save the contacts
    }
    
    func didUpdateContact(_ contact : Contact, at index : Int) {
        contacts[index] = contact //update the contact
        tableView.reloadData() //refresh main page
        saveContacts() //save the contacts
    }
}





class ContactEntryVIewController : UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var contact : Contact?  //store the contact to be edited
    var contactIndex : Int?  // store the index of contact
    var isEditMode : Bool = false  //track whether it is edit mode
    
    weak var delegate: ContactDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // If in edit mode, populate the text fields with the contact's data
        if let contact = contact {
                    nameTextField.text = contact.name
                    surnameTextField.text = contact.surname
                    companyTextField.text = contact.company
                    numberTextField.text = contact.phoneNumber
                    emailTextField.text = contact.email
                }
        }
    //Done button
    @IBAction func SaveBut(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let number = numberTextField.text, !number.isEmpty else {
            showAlert(message: "Name and Phone Number are required.")
            return
        }
        
        // Validate that the phone number is numeric
        if !isNumeric(number) {
            showAlert(message: "Phone Number must be numeric.")
            return
        }
        
        let updatedContact = Contact(
            name: name,
            surname: surnameTextField.text ?? "",
            company: companyTextField.text ?? "",
            phoneNumber: number,
            email: emailTextField.text ?? ""
        )
        
        if isEditMode, let index = contactIndex {
            // Updating the existing contact
            delegate?.didUpdateContact(updatedContact, at: index)
        } else {
            // Add new contact
            delegate?.didAddContact(updatedContact)
        }
        
        navigationController?.popViewController(animated: true)
    }

    // Helper function to check if the string is numeric
    private func isNumeric(_ string: String) -> Bool {
        let numberSet = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: numberSet) == nil
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


