import FluidInterfaceKit

final class FirstViewController: FluidViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
       
    fluidPush(SecondViewController(), target: .current, relation: .hierarchicalNavigation)
  }
}
