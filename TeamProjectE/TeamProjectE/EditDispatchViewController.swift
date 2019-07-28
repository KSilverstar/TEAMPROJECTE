// PROGRAMMERs: Kenia Aleman-Osorio, Christian Fernandez (Team Project E)
// PANTHERID:  1349535
// CLASS:      COP465501 TR 5:00
// INSTRUCTOR: Steve Luis ECS 282
// ASSIGNMENT: Final Project, Deliverable 2
// DUE:        Saturday 07/27/2019

import UIKit
import CoreData

//Custom cell
class CustomDispatchCell: UITableViewCell{
    @IBOutlet weak var customerNameCol: UILabel!
    @IBOutlet weak var customerVehicleCol: UILabel!
    @IBOutlet weak var towStatusCol: UILabel!
    @IBOutlet weak var towStatusTimeCol: UILabel!
}

class EditDispatchViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dispatchDetailViewController: DispatchDetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var customers: [NSManagedObject] = []
    
    let dateFormatter = DateFormatter()
    
    //Color schemes
    var waitingColor    =       UIColor(red: 235/255,   green: 87/255,  blue: 87/255,  alpha: 1.0)
    var dispatchedColor =       UIColor(red: 111/255,   green: 207/255, blue: 151/255, alpha: 1.0)
    var completedColor  =       UIColor(red: 33/255,    green: 150/255, blue: 83/255,  alpha: 1.0)
    
    var index:IndexPath?
    
    //var dispatchDb = DispatchDatabase.sharedInstance --Being replaced by CoreData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = 100
        
        navigationItem.leftBarButtonItem = editButtonItem

        
        //CoreData instantiation
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        //Search delegate
        searchBar.delegate = self
        
        // Get the height of the status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
    }
    
    //Search bar   functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if !searchText.isEmpty{
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "first_name contains[c] %@", searchText) //Query CoreData
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Dispatch")
            fetchRequest.predicate = predicate
            do{
                customers = try managedObjectContext?.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError{
                print("Could not fetch. \(error)")
            }
        }
        tableView.reloadData()
    }
    
    //PersistentContainer
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TowData")
        container.loadPersistentStores{ (description, error) in
            if let error = error{
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    //Reload the table view so user can immediately see any changes made.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: TableView Code
    
    //Couple DataCore objects with TableCell indices
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomDispatchCell", for: indexPath) as! CustomDispatchCell
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return CGFloat(67)
    }
    
    // Returns the count of CoreData objects
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //OLD 7.24.19 Kenia -- Populated by number of records in singleton
        //print(dispatchDb.allPDispatches.count)
        //return dispatchDb.allPDispatches.count
        
        //UPDATED 7.24.19 Christian -- Populated by number of records in CoreData DB
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int{
        return fetchedResultsController.sections?.count ?? 0
    }
    
    //Segue declaration
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Pick between add or show
        if(segue.identifier == "addDispatch"){
            let myAddDispatchViewController = segue.destination as! AddDispatchViewController
        }
        if(segue.identifier == "showDetail"){
            let myDispatchDetailViewController = segue.destination as! DispatchDetailViewController
            myDispatchDetailViewController.myDispatch = fetchedResultsController.object(at: index!)  //pass current cell object to detail view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //update global index
        index = indexPath
        performSegue(withIdentifier: "showDetail", sender: self) //call segue
    }
    
    //Deleting a cell will delete the CoreData object
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do{
                try context.save()
            } catch{
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // All rows can be editted
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //
    @IBAction func toggleEditingDispatchItem(_ sender: UIButton) {
        // If you are currently in editing mode...
        if isEditing {
            // Change text of button to inform user of state
            sender.setTitle("Edit", for: .normal)
            
            // Turn off editing mode
            setEditing(false, animated: true)
        } else {
            // Change text of button to inform user of state
            sender.setTitle("Done", for: .normal)
            
            // Enter editing mode
            setEditing(true, animated: true)
        }
    }
        
    //How the custom cell will get its information from DataCore. Also change colors based on dispatch status
    func configureCell(_ cell: CustomDispatchCell, withEvent dispatch: Dispatch){
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        
        let currentDate = dateFormatter.string(from: dispatch.status_time! as Date)
        
        cell.customerNameCol.text = dispatch.first_name!.description + " " + dispatch.last_name!.description
        cell.customerVehicleCol.text = dispatch.car_make!.description + " " + dispatch.car_model!.description
        cell.towStatusCol.text = dispatch.status!.description
        cell.towStatusTimeCol.text = currentDate
        
        if(cell.towStatusCol.text == "Waiting"){
            cell.towStatusCol.textColor = waitingColor
        }else if(cell.towStatusCol.text == "Dispatched"){
            cell.towStatusCol.textColor = dispatchedColor
        }else if(cell.towStatusCol.text == "Completed"){
            cell.towStatusCol.textColor = completedColor
        }
    }
        
    // MARK: Controllers
        
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
    
    //Updates to the controller will also update the table
    func controllerWillChangeContent(_controller: NSFetchedResultsController<NSFetchRequestResult>){
        tableView.beginUpdates()
    }
    
    //MARK: NSFetched controller handlers
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType){
        switch type{
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath:IndexPath?){
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! CustomDispatchCell, withEvent: anObject as! Dispatch)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! CustomDispatchCell, withEvent: anObject as! Dispatch)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        tableView.endUpdates()
    }
    
    //Keyboard dismissal
    func dismissKeyboard(){
        view.endEditing(true)
    }
        
}
