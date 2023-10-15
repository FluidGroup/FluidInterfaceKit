import FluidStack

final class FirstViewController: FluidViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
           
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    fluidPush(SecondViewController(), target: .current, relation: .hierarchicalNavigation)
  }
}
