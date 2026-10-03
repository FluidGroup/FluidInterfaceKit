import UIKit

/// Displays the demo's retained views in a vertically scrolling, self-sizing grid.
///
/// Content views keep their identity and interactions as cells scroll offscreen.
/// Only the collection view cells are reused; this view owns the supplied content
/// until a subsequent call to ``setContents(_:)`` replaces it.
final class DemoGridView: UICollectionView, UICollectionViewDataSource {

  private var contents: [UIView] = []

  init(numberOfColumns: Int) {
    precondition(numberOfColumns > 0)

    let column = NSCollectionLayoutGroup.horizontal(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(10)
      ),
      subitems: (0..<numberOfColumns).map { _ in
        NSCollectionLayoutItem(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1 / CGFloat(numberOfColumns)),
            heightDimension: .estimated(100)
          )
        )
      }
    )

    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(100)
      ),
      subitems: [column]
    )

    let layout = UICollectionViewCompositionalLayout(
      section: NSCollectionLayoutSection(group: group)
    )
    layout.configuration.scrollDirection = .vertical

    super.init(frame: .zero, collectionViewLayout: layout)

    register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.reuseIdentifier)
    dataSource = self
    backgroundColor = .clear
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Replaces the displayed views without recreating their state or interactions.
  func setContents(_ contents: [UIView]) {
    self.contents = contents
    reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    contents.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ContentCell.reuseIdentifier,
      for: indexPath
    ) as! ContentCell
    cell.setContent(contents[indexPath.item])
    return cell
  }

  /// Temporarily hosts one retained content view while its item is onscreen.
  private final class ContentCell: UICollectionViewCell {

    static let reuseIdentifier = "DemoGridContent"

    override func prepareForReuse() {
      super.prepareForReuse()
      contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func setContent(_ content: UIView) {
      guard content.superview !== contentView else { return }

      contentView.subviews.forEach { $0.removeFromSuperview() }
      contentView.addSubview(content)
      content.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        content.topAnchor.constraint(equalTo: contentView.topAnchor),
        content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      ])
    }
  }
}
