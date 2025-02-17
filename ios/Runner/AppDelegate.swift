import Flutter
import UIKit
import Firebase
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Firebase 초기화
    FirebaseApp.configure()

    // ✅ Google 로그인 설정
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        fatalError("Google Client ID가 설정되지 않았습니다.")
    }

    let signInConfig = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = signInConfig

    // ✅ Flutter 플러그인 등록
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
