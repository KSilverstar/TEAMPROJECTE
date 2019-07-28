// PROGRAMMERs: Kenia Aleman-Osorio, Christian Fernandez (Team Project E)
// PANTHERID:  1349535
// CLASS:      COP465501 TR 5:00
// INSTRUCTOR: Steve Luis ECS 282
// ASSIGNMENT: Final Project, Deliverable 2
// DUE:        Saturday 07/27/2019



import UIKit
import CoreData

class DispatchDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    //Labels, buttons, txt fields
    @IBOutlet weak var customerImageView: UIImageView!
    
    @IBOutlet weak var customerVehicleLabel: UILabel!
    @IBOutlet weak var dispatchStatusLabel: UILabel!
    @IBOutlet weak var dispatchStatusTimeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var addressLocationLabel: UITextField!
    @IBOutlet weak var vehicleMakeLabel: UITextField!
    @IBOutlet weak var vehicleModelLabel: UITextField!
    @IBOutlet weak var vehicleYearLabel: UITextField!
    @IBOutlet weak var notesLabel: UITextField!
    @IBOutlet weak var addressDestinationLabel: UITextField!
    
    @IBOutlet weak var waitingButton: UIButton!
    @IBOutlet weak var dispatchedButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    
    
    //Color Scheme
    var waitingColor    =       UIColor(red: 235/255,   green: 87/255,  blue: 87/255,  alpha: 1.0)
    var dispatchedColor =       UIColor(red: 111/255,   green: 207/255, blue: 151/255, alpha: 1.0)
    var completedColor  =       UIColor(red: 33/255,    green: 150/255, blue: 83/255,  alpha: 1.0)
    var onTextColor     =       UIColor(red: 255/255,   green: 255/255, blue: 255/255, alpha: 1.0)
    var offTextColor    =       UIColor(red: 0/255,     green: 122/255, blue: 255/255, alpha: 1.0)
    var offBgColor      =       UIColor(red: 244/255,   green: 244/255, blue: 244/255, alpha: 1.0)
    
    let dateFormatter = DateFormatter()
    
    //the CoreData object that is passed via segue
    var myDispatch: Dispatch!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //gesture recognition for keyboard dismissal
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //add the described gesutre recognizer to the view
        view.addGestureRecognizer(tap)
        
        //Run the UI refresh based on passed object
        configureDetails()
        setButtonsOnLoad(curStatus: dispatchStatusLabel.text!)
    }
    
    //Update the timestamp based on objects current value
    func setDateLabel(){
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        
        let currentDate = dateFormatter.string(from: myDispatch.status_time! as Date)
        
        dispatchStatusTimeLabel.text = "since " + currentDate
    }
    
    //MARK: Dispatch status buttons. These buttons will update colors of UI and the CoreData object
    
    @IBAction func setWaitingStatus(_ sender: Any) {
        myDispatch.setValue("Waiting", forKey: "status")
        myDispatch.setValue(NSDate(), forKey:"status_time")
        setDateLabel()
        
        dispatchStatusLabel.text = "Waiting"
        dispatchStatusLabel.textColor = waitingColor
        
        //Turn on
        waitingButton.setTitleColor(onTextColor, for: .normal)
        waitingButton.backgroundColor = waitingColor
        
        //Turn off
        dispatchedButton.setTitleColor(offTextColor, for: .normal)
        dispatchedButton.backgroundColor = offBgColor
        
        completedButton.setTitleColor(offTextColor, for: .normal)
        completedButton.backgroundColor = offBgColor
    }
    
    @IBAction func setDispatchStatus(_ sender: Any) {
        myDispatch.setValue("Dispatched", forKey: "status")
        myDispatch.setValue(NSDate(), forKey:"status_time")
        setDateLabel()
        
        dispatchStatusLabel.text = "Dispatched"
        dispatchStatusLabel.textColor = dispatchedColor
        
        //On
        dispatchedButton.setTitleColor(onTextColor, for: .normal)
        dispatchedButton.backgroundColor = dispatchedColor
        
        //Off
        waitingButton.setTitleColor(offTextColor, for: .normal)
        waitingButton.backgroundColor = offBgColor
        
        completedButton.setTitleColor(offTextColor, for: .normal)
        completedButton.backgroundColor = offBgColor
        
    }
    
    @IBAction func setCompletedStatus(_ sender: Any) {
        myDispatch.setValue("Completed", forKey: "status")
        myDispatch.setValue(NSDate(), forKey:"status_time")
        setDateLabel()
        
        dispatchStatusLabel.text = "Completed"
        dispatchStatusLabel.textColor = completedColor
        
        //On
        completedButton.setTitleColor(onTextColor, for: .normal)
        completedButton.backgroundColor = completedColor
        
        //Off
        waitingButton.setTitleColor(offTextColor, for: .normal)
        waitingButton.backgroundColor = offBgColor
        
        dispatchedButton.setTitleColor(offTextColor, for: .normal)
        dispatchedButton.backgroundColor = offBgColor
        
    }
    
    //Called on load to update UI button based on dispatch status of object
    func setButtonsOnLoad(curStatus: String){
        if curStatus == "Waiting" {
            //Turn on
            dispatchStatusLabel.textColor = waitingColor
            
            waitingButton.setTitleColor(onTextColor, for: .normal)
            waitingButton.backgroundColor = waitingColor
            
            //Turn off
            dispatchedButton.setTitleColor(offTextColor, for: .normal)
            dispatchedButton.backgroundColor = offBgColor
            
            completedButton.setTitleColor(offTextColor, for: .normal)
            completedButton.backgroundColor = offBgColor
            
        } else if curStatus == "Dispatched" {
            //On
            dispatchStatusLabel.textColor = dispatchedColor
            
            dispatchedButton.setTitleColor(onTextColor, for: .normal)
            dispatchedButton.backgroundColor = dispatchedColor
            
            //Off
            waitingButton.setTitleColor(offTextColor, for: .normal)
            waitingButton.backgroundColor = offBgColor
            
            completedButton.setTitleColor(offTextColor, for: .normal)
            completedButton.backgroundColor = offBgColor
            
        } else if curStatus == "Completed" {
            //On
            dispatchStatusLabel.textColor = completedColor
            
            completedButton.setTitleColor(onTextColor, for: .normal)
            completedButton.backgroundColor = completedColor
            
            //Off
            waitingButton.setTitleColor(offTextColor, for: .normal)
            waitingButton.backgroundColor = offBgColor
            
            dispatchedButton.setTitleColor(offTextColor, for: .normal)
            dispatchedButton.backgroundColor = offBgColor
        }
    }
    
    //Load in all the information from the object to the UI
    func configureDetails(){
        customerVehicleLabel.text = myDispatch.car_make!.description + " " + myDispatch.car_model!.description
        dispatchStatusLabel.text = myDispatch.status!.description
        setDateLabel()
        
        
        nameLabel.text = myDispatch.first_name!.description
        lastNameLabel.text = myDispatch.last_name!.description
        phoneNumberLabel.text = myDispatch.phone!.description
        addressLocationLabel.text = myDispatch.address_location!.description
        vehicleMakeLabel.text = myDispatch.car_make!.description
        vehicleModelLabel.text = myDispatch.car_model!.description
        vehicleYearLabel.text = myDispatch.car_year!.description
        notesLabel.text = myDispatch.notes!.description
        addressDestinationLabel.text = myDispatch.address_destination!.description
        if(myDispatch.user_image != nil){
            customerImageView.image = UIImage(data: myDispatch.user_image! as Data)
        }
        //cell.towStatusTimeCol.text = dispatch.status_time!.description
    }
    
    //Send edited data to the CoreData
    @IBAction func updateProperties(_ sender: Any) {
        myDispatch.setValue(nameLabel.text, forKey:"first_name")
        myDispatch.setValue(lastNameLabel.text, forKey:"last_name")
        myDispatch.setValue(phoneNumberLabel.text, forKey: "phone")
        myDispatch.setValue(addressLocationLabel.text, forKey: "address_location")
        myDispatch.setValue(vehicleMakeLabel.text, forKey: "car_make")
        myDispatch.setValue(vehicleModelLabel.text, forKey: "car_model")
        myDispatch.setValue(vehicleYearLabel.text, forKey: "car_year")
        myDispatch.setValue(notesLabel.text, forKey: "notes")
        myDispatch.setValue(addressDestinationLabel.text, forKey: "address_destination")
        
        configureDetails()
    }
    
    //Called when the gesture listener for tap is triggered, it will dismiss the keyboard
    func dismissKeyboard(){
        view.endEditing(true)
    }
}
