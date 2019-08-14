import RxSwift

class SendEthereumInteractor {
    weak var delegate: ISendEthereumInteractorDelegate?

    private let disposeBag = DisposeBag()

    private let wallet: Wallet
    private let adapter: ISendEthereumAdapter

    init(wallet: Wallet, adapter: ISendEthereumAdapter) {
        self.wallet = wallet
        self.adapter = adapter
    }

}

extension SendEthereumInteractor: ISendEthereumInteractor {

    var coin: Coin {
        return wallet.coin
    }

    func availableBalance(gasPrice: Int) -> Decimal {
        return adapter.availableBalance(gasPrice: gasPrice)
    }

    var ethereumBalance: Decimal {
        return adapter.ethereumBalance
    }

    func validate(address: String) throws {
        try adapter.validate(address: address)
    }

    func fee(gasPrice: Int) -> Decimal {
        return adapter.fee(gasPrice: gasPrice)
    }

    func send(amount: Decimal, address: String, gasPrice: Int) {
        adapter.sendSingle(amount: amount, address: address, gasPrice: gasPrice)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] in
                    self?.delegate?.didSend()
                }, onError: { [weak self] error in
                    self?.delegate?.didFailToSend(error: error)
                })
                .disposed(by: disposeBag)
    }

}
