import UIKit

import Web3Modal
import Auth
import WalletConnectRelay
import WalletConnectNetworking
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var publishers = Set<AnyCancellable>()

    private let app = Application()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Networking.configure(
            groupIdentifier: "group.com.walletconnect.dapp",
            projectId: InputConfig.projectId,
            socketFactory: DefaultSocketFactory()
        )
        Auth.configure(crypto: DefaultCryptoProvider())
        
        let metadata = AppMetadata(
            name: "Swift Dapp",
            description: "WalletConnect DApp sample",
            url: "wallet.connect",
            icons: ["https://avatars.githubusercontent.com/u/37784886"],
            redirect: AppMetadata.Redirect(native: "wcdapp://", universal: nil)
        )
        
        Web3Modal.configure(
            projectId: InputConfig.projectId,
            metadata: metadata
        )

        Sign.instance.logsPublisher.sink { log in
            switch log {
            case .error(let logMessage):
                AlertPresenter.present(message: logMessage.message, type: .error)
            default: return
            }
        }.store(in: &publishers)

        Sign.instance.socketConnectionStatusPublisher.sink { status in
            switch status {
            case .connected:
                AlertPresenter.present(message: "Your web socket has connected", type: .success)
            case .disconnected:
                AlertPresenter.present(message: "Your web socket is disconnected", type: .warning)
            }
        }.store(in: &publishers)

        setupWindow(scene: scene)
    }

    private func setupWindow(scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let viewController = MainModule.create(app: app)

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
