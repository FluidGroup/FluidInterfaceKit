import FluidStack

final class RootViewController: FluidStackController {
 
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    addContentViewController(FirstViewController(), transition: .disabled)
  }
}
