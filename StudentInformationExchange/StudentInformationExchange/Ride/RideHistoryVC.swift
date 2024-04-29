import UIKit

struct Booking: Codable {
    var pickupLocation: String
    var pickupTime: String
    var dropLocation: String
    var dropTime: String
    var documentId :String?
    var passangers :Int?
    var createdBy :String?
}

class RiderHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var bookings = [Booking]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCells([EventListCell.self])
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }

    func loadData() {
        FireStoreManager.shared.getBookingHistory { bookings in
            self.bookings = bookings
            self.tableView.reloadData()
        }
    }
}

extension RiderHistoryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell", for: indexPath) as! EventListCell
        let booking = bookings[indexPath.row]

        let desc = """
            Pickup: \(booking.pickupLocation)
            Pickup Time: \(booking.pickupTime)
            
            Drop: \(booking.dropLocation)
            
            """
        
        cell.setData(title: "Booking \(indexPath.row + 1)", desc:desc)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RideVC") as! RideVC
        vc.booking = bookings[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
