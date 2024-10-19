# iOS Contacts App

This iOS Contacts app allows users to add, update, and search for contacts. The app uses `UITableView` to display the contacts and `UserDefaults` for data persistence.

## Code Structure

### 1. Contact Struct

```swift
struct Contact: Codable {
    var name: String
    var surname: String
    var company: String
    var phoneNumber: String
    var email: String
}
```
- Purpose: Represents a contact with attributes such as name, surname, company, phone number, and email.
- Codable: This allows instances of Contact to be encoded to and decoded from JSON format for saving in
UserDefaults.

### 2. TableViewController
```swift
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
```
- ```UISearchBarDelegate:``` Allows handling search bar interactions.
- ```var contacts: [Contact]= []``` : Stores all contacts.
- ```var filteredContacts: [Contact] = []```: Stores contacts that match the search criteria.
- ```var isSearching: Bool = false ``` : Flag to indicate if the search bar is being used.


___Methods___

- ```viewDidLoad:```
Registers a reusable cell identifier for the table view.
Loads existing contacts from UserDefaults.
Sets the search bar delegate.
- ```searchBar(_:textDidChange:):```
Triggered when the user types in the search bar.
Updates the filteredContacts based on whether the search text is empty or matches the contact names.
Reloads the table view to display the updated list.
- ```saveContacts:```
Encodes the contacts array to JSON and saves it to UserDefaults.
- ```loadContacts:```
Retrieves and decodes the saved contacts from UserDefaults.
- ``tableView(_:cellForRowAt:):``
Configures each cell in the table view.
Uses filteredContacts if searching, otherwise uses the full contacts list.
- ```tableView(_:numberOfRowsInSection:):```
Returns the number of rows in the table view based on whether the app is in search mode.
- ```tableView(_:didSelectRowAt:):```
Handles the selection of a contact and performs a segue to the contact entry view controller for editing.
- ```prepare(for:sender:):```
Prepares data to pass to the contact entry view controller during the segue.

### 3. ContactEntryViewController
```swift
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
        let updatedContact = Contact(
            name : name,
            surname : surnameTextField.text ?? "",
            company: companyTextField.text ?? "",
            phoneNumber: number,
            email : emailTextField.text ?? ""
        )
        if isEditMode, let index = contactIndex {
            //updating the existing contact
            delegate?.didUpdateContact(updatedContact, at: index)
        } else {
            //add new contact
            delegate?.didAddContact(updatedContact)
        }
            navigationController?.popViewController(animated: true)
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
```
- `var contact:` Contact?: Holds the contact being edited (if any).
- `var contactIndex:` Int?: Index of the contact in the contacts array.
- `var isEditMode: Bool = false:` Indicates if the controller is in edit mode.

___Methods___

- `viewDidLoad:`
Populates text fields with existing contact information if in edit mode.
- `SaveBut:`
Validates input from text fields.
Creates or updates a Contact instance and calls the delegate methods to add or update the contact.
Navigates back to the previous screen after saving.
- `showAlert:`
Displays an alert for error messages.

### 4. Protocol: ContactDelegate

```swift
protocol ContactDelegate: AnyObject {
    func didAddContact(_ contact: Contact)
    func didUpdateContact(_ contact: Contact, at index: Int)
}
```
- `Purpose:` Defines methods for adding and updating contacts.
- `Usage:` Implemented by the ``TableViewController`` to update the contacts list when changes occur.

### 5. TableViewController Extension

```swift
extension TableViewController: ContactDelegate {
    func didAddContact(_ contact: Contact) {
        contacts.append(contact) // Add new contact
        tableView.reloadData() // Refresh main page
        saveContacts() // Save the contacts
    }
    
    func didUpdateContact(_ contact: Contact, at index: Int) {
        contacts[index] = contact // Update the contact
        tableView.reloadData() // Refresh main page
        saveContacts() // Save the contacts
    }
}
```
- `Purpose:` Implements the ```ContactDelegate``` protocol methods.
- `didAddContact:` Appends a new contact to the contacts array, reloads the table view, and saves the contacts.
- `didUpdateContact:` Updates an existing contact in the contacts array, reloads the table view, and saves the contacts.

