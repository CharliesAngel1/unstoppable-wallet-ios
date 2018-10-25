import UIKit
import SnapKit

struct TransactionFilterItem {
    let coin: Coin?
    let name: String
}

class TransactionsViewController: UITableViewController {

    let delegate: ITransactionsViewDelegate

    private let cellName = String(describing: TransactionCell.self)

    private let filterHeaderView = TransactionCurrenciesHeaderView()

    init(delegate: ITransactionsViewDelegate) {
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        tabBarItem = UITabBarItem(title: "transactions.tab_bar_item".localized, image: UIImage(named: "transactions.tab_bar_item"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        filterHeaderView.onSelectCoin = { coin in
            self.delegate.onFilterSelect(coin: coin)
        }

        tableView.backgroundColor = AppTheme.controllerBackground
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.registerCell(forClass: TransactionCell.self)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 0
        tableView.delaysContentTouches = false

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        delegate.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func onRefresh() {
        delegate.refresh()
    }

}

extension TransactionsViewController: ITransactionsView {

    func set(title: String) {
        self.title = title.localized
    }

    func show(filters: [TransactionFilterItem]) {
        filterHeaderView.reload(filters: filters)
    }

    func didRefresh() {
        refreshControl?.endRefreshing()
    }

    func reload() {
        tableView.reloadData()
    }

}

extension TransactionsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.itemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TransactionCell {
            cell.bind(item: delegate.item(forIndex: indexPath.row))
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = delegate.item(forIndex: indexPath.row)
        delegate.onTransactionItemClick(transaction: item)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionsTheme.cellHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransactionsFilterTheme.filterHeaderHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate.itemsCount > 0 ? filterHeaderView : nil
    }

}
