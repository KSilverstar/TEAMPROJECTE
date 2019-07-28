// PROGRAMMERs: Kenia Aleman-Osorio, Christian Fernandez (Team Project E)
// PANTHERID:  1349535
// CLASS:      COP465501 TR 5:00
// INSTRUCTOR: Steve Luis ECS 282
// ASSIGNMENT: Final Project, Deliverable 2
// DUE:        Saturday 07/27/2019


import UIKit
import CoreData

class AddDispatchViewController: UIViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Textfields and Views
    @IBOutlet weak var customerImageView: UIImageView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var carMakeTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    @IBOutlet weak var carYearTextField: UITextField!
    @IBOutlet weak var carColorTextField: UITextField!
    
    @IBOutlet weak var addressLocationTextField: UITextField!
    @IBOutlet weak var addressDestinationTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    
    //Alerts
    let alertSuccess = UIAlertController(title: "Success", message: "Dispatch Added", preferredStyle: .alert)
    let alertFail = UIAlertController(title: "Failure", message: "Missing a field (notes are optional)", preferredStyle: .alert)
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //CoreData instantiation
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        //gesture recognition for keyboard dismissal
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //add the described gesutre recognizer to the view
        view.addGestureRecognizer(tap)
        
        //Set responses for alerts
        alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertFail.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    
    //On click add, submit to CoreData. Validate first
    @IBAction func submitNewReocrd(_ sender: Any) {
        
        if(firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty
            || phoneTextField.text!.isEmpty || carMakeTextField.text!.isEmpty
            || carModelTextField.text!.isEmpty || carYearTextField.text!.isEmpty
            || carColorTextField.text!.isEmpty || addressLocationTextField.text!.isEmpty
            || addressDestinationTextField.text!.isEmpty){
            
            self.present(alertFail, animated: true)
        } else{
            insertNewObject()
            self.present(alertSuccess, animated: true)
        }
    }
    
    //Add a cell--Only used for testing
    func insertNewObject(){
        let context = self.fetchedResultsController.managedObjectContext    //Retrieve the DataCore interface
        let newDispatch = Dispatch(context: context)                        //New object to be added to the DB
        
        //Set properties for record
        newDispatch.dispatch_id                 =   1
        newDispatch.first_name                  =   firstNameTextField.text
        newDispatch.last_name                   =   lastNameTextField.text
        newDispatch.car_make                    =   carMakeTextField.text
        newDispatch.car_model                   =   carModelTextField.text
        newDispatch.car_year                    =   carYearTextField.text
        newDispatch.car_color                   =   carColorTextField.text
        newDispatch.status                      =   "Waiting"
        newDispatch.status_time                 =   NSDate()
        newDispatch.phone                       =   phoneTextField.text
        newDispatch.address_location            =   addressLocationTextField.text
        newDispatch.address_destination         =   addressDestinationTextField.text
        newDispatch.notes                       =   notesTextField.text
        if customerImageView.image != nil {
            newDispatch.user_image                  =   UIImagePNGRepresentation(customerImageView.image!)! as NSData
        }
        
        
        //Save record
        do{
            try context.save()
        } catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    //Called when the gesture listener for tap is triggered, it will dismiss the keyboard
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //Run the user interfaces for selecting an image, runs when user selecrs Pick image"
    @IBAction func importImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true){
            
        }
        
    }
    
    //Safely handles image retrieval and displays permissin prompt
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            customerImageView.image = image
        } else{
            //error ness
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: CoreData controllers/containers
    
    //Controller for retrieving results from the MOC
    var fetchedResultsController: NSFetchedResultsController<Dispatch>{
        if _fetchedResultsController != nil{
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Dispatch> = Dispatch.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "status_time", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do{
            try _fetchedResultsController!.performFetch()
        } catch{
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Dispatch>? = nil
    
    //Prevents a crash
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
    }
}
