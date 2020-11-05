import UIKit
import ThemeKit
import RxSwift
import RxCocoa

protocol IOpenControllerDelegate: AnyObject {
    func open(controller: UIViewController)
}

class RecipientInputCell: VerifiedInputCell {
    private let disposeBag = DisposeBag()
    weak var openDelegate: IOpenControllerDelegate?

    override init(viewModel: IVerifiedInputViewModel) {
        super.init(viewModel: viewModel)

        let buttons = [
            InputFieldButtonItem(style: .secondaryIcon, icon: UIImage(named: "Send Scan Icon"), visible: .onEmpty) { [weak self] in
                self?.onScanTapped()
            },
            InputFieldButtonItem(style: .secondaryDefault, title: "button.paste".localized, visible: .onEmpty) { [weak self] in
                self?.onPasteTapped()
            },
            InputFieldButtonItem(style: .secondaryIcon, icon: UIImage(named: "Send Delete Icon"), visible: .onFilled) { [weak self] in
                self?.onDeleteTapped()
            }
        ]

        append(items: buttons)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func onScanTapped() {
        let scanQrViewController = ScanQrViewController()
        scanQrViewController.delegate = self
        openDelegate?.open(controller: scanQrViewController)
    }

    private func onPasteTapped() {
        guard let text = UIPasteboard.general.string?.replacingOccurrences(of: "\n", with: " ") else {
            return
        }
        inputText = text
        viewModel.inputFieldDidChange(text: text)
    }

    private func onDeleteTapped() {
        inputText = nil
        viewModel.inputFieldDidChange(text: nil)
    }

}

extension RecipientInputCell: IScanQrViewControllerDelegate {

    func didScan(string: String) {
        inputText = string
        viewModel.inputFieldDidChange(text: string)
    }

}