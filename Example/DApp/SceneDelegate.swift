import UIKit
import Starscream
import WalletConnectRelay

extension WebSocket: WebSocketConnecting { }

struct SocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        return WebSocket(url: url)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let signCoordinator = SignCoordinator()
    private let authCoordinator = AuthCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Relay.configure(projectId: "3ca2919724fbfa5456a25194e369a8b4", socketFactory: SocketFactory())

        setupWindow(scene: scene)
    }

    private func setupWindow(scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let tabController = UITabBarController()
        tabController.viewControllers = [
            signCoordinator.navigationController,
            authCoordinator.navigationController
        ]

        signCoordinator.start()
        authCoordinator.start()

        window?.rootViewController = tabController
        window?.makeKeyAndVisible()
    }
}
