import UIKit

class ViewController:UIViewController
{
    @IBOutlet weak var arcControl: GNArcControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        arcControl.valueDidChange = { value in
            print("Value:",value)
        }
    }
}
