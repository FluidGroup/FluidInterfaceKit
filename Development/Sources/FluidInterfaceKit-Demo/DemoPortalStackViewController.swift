import FluidPortal
import MondrianLayout
import UIKit

/// Demonstrates portal content that remains visible outside scrolling list cells.
final class DemoPortalStackViewController: UIViewController {

  private let listView: UICollectionView = {
    let item = NSCollectionLayoutItem(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(100)
      )
    )
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(100)
      ),
      subitems: [item]
    )
    let layout = UICollectionViewCompositionalLayout(
      section: NSCollectionLayoutSection(group: group)
    )
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.delaysContentTouches = false
    collectionView.isPrefetchingEnabled = false
    return collectionView
  }()

  private var dataSource: UICollectionViewDiffableDataSource<String, String>?
  private let portalStackView = PortalStackView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .white

    Mondrian.buildSubviews(on: self.view) {

      ZStackBlock(alignment: .attach(.all)) {

        listView

        portalStackView
      }

    }

    listView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

    dataSource = UICollectionViewDiffableDataSource<String, String>(
      collectionView: listView,
      cellProvider: { [portalStackView] collectionView, indexPath, item in

        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: Cell.reuseIdentifier,
          for: indexPath
        ) as! Cell
        cell.setData(item, stack: portalStackView)

        return cell
      }
    )

    setContents(
      [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
      ]
    )

  }

  /// Updates the scrolling rows while preserving each string's diffable identity.
  private func setContents(_ contents: [String]) {
    guard let dataSource else {
      preconditionFailure("Configure the data source before updating the portal rows.")
    }

    var snapshot = NSDiffableDataSourceSnapshot<String, String>()
    snapshot.appendSections(["A"])
    snapshot.appendItems(contents, toSection: "A")
    dataSource.apply(snapshot)
  }

  /// Hosts a row's label and a platter registered with the enclosing portal stack.
  private final class Cell: UICollectionViewCell {

    static let reuseIdentifier = "PortalStackCell"

    private let label = UILabel()

    private let containerView = TipContainerView(contentView: UIButton(type: .system), portalStackView: nil)

    override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.backgroundColor = .white

      Mondrian.buildSubviews(on: contentView) {
        VStackBlock {
          label
          containerView.viewBlock
            .padding(.leading, 200)
        }
        .padding(20)
      }

      let dummyBox = UIView()
      dummyBox.frame.size = .init(width: 100, height: 100)
      dummyBox.backgroundColor = .blue.withAlphaComponent(0.5)

      containerView.platterView.addSubview(dummyBox)
      dummyBox.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        dummyBox.topAnchor.constraint(equalTo: containerView.platterView.topAnchor),
        dummyBox.bottomAnchor.constraint(equalTo: containerView.platterView.bottomAnchor),
        dummyBox.leadingAnchor.constraint(equalTo: containerView.platterView.leadingAnchor),
        dummyBox.trailingAnchor.constraint(equalTo: containerView.platterView.trailingAnchor),
        dummyBox.widthAnchor.constraint(equalToConstant: 600),
        dummyBox.heightAnchor.constraint(equalToConstant: 100),
      
      ])

    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    func setData(_ string: String, stack: PortalStackView) {
      self.label.text = string
      self.containerView.contentView.setTitle(string, for: .normal)
//      stack.register(view: button)
    }
  }
}

/// Keeps content in its row while projecting a platter through a portal stack.
///
/// An explicitly supplied stack takes precedence over one found in the view
/// hierarchy. The platter is registered only while this view belongs to a window.
final class TipContainerView<ContentView: UIView>: UIView {

  let contentView: ContentView
  let platterView: UIView = .init()

  private var platterViewXAnchor: NSLayoutConstraint!
  private var platterViewYAnchor: NSLayoutConstraint!
  private var platterViewMaxWidthAnchor: NSLayoutConstraint!

  private let portalStackView: PortalStackView?

  init(contentView: ContentView, portalStackView: PortalStackView?) {
    self.contentView = contentView
    self.portalStackView = portalStackView

    super.init(frame: .null)

    addSubview(contentView)
    addSubview(platterView)

    contentView.translatesAutoresizingMaskIntoConstraints = false
    platterView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    platterViewXAnchor = platterView.centerXAnchor.constraint(equalTo: centerXAnchor)
    platterViewYAnchor = platterView.centerYAnchor.constraint(equalTo: centerYAnchor)
    platterViewMaxWidthAnchor = platterView.widthAnchor.constraint(lessThanOrEqualToConstant: 1000)

    NSLayoutConstraint.activate([
      platterViewXAnchor,
      platterViewYAnchor,
      platterViewMaxWidthAnchor,
    ])

  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if window != nil {
      updateFrame()
      targetPortalStackView()?.register(view: platterView)
    } else {
      targetPortalStackView()?.remove(view: platterView)
    }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func targetPortalStackView() -> PortalStackView? {

    if let portalStackView {
      return portalStackView
    }

    func find(parent: UIView) -> PortalStackView? {
      for view in parent.subviews {
        if let portal = view as? PortalStackView {
          return portal
        }
      }
      guard let superview = parent.superview else { return nil }
      return find(parent: superview)
    }

    guard let superview = superview else { return nil }

    return find(parent: superview)

  }

  override var center: CGPoint {
    didSet {
      updateFrame()
    }
  }

  override var bounds: CGRect {
    didSet {
      updateFrame()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateFrame()
  }


  private func updateFrame() {

    guard let window = window else {
      return
    }

    let position = convert(bounds, to: window)

    platterViewXAnchor.constant = -(position.minX - ((window.bounds.width / 2) - (position.size.width / 2)))
    platterViewMaxWidthAnchor.constant = window.bounds.size.width

  }
}
