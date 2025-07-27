import Flutter
import UIKit
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure audio session for recording
    configureAudioSession()
    
    // Setup Flutter method channel for audio session configuration
    setupAudioSessionChannel()
    
    // Request notification permissions on app launch
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    // Register for remote notifications (if needed in future)
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle notification when app is in foreground
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.alert, .badge, .sound])
  }
  
  // Handle notification tap
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Handle the notification response
    completionHandler()
  }
  
  // MARK: - Audio Session Configuration
  
  private func configureAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      
      // Configure audio session for recording and playback
      try audioSession.setCategory(.playAndRecord, 
                                   mode: .default, 
                                   options: [.defaultToSpeaker, .allowBluetoothA2DP])
      
      try audioSession.setActive(true)
      
      print("✅ Audio session configured successfully")
    } catch {
      print("❌ Failed to configure audio session: \(error)")
    }
  }
  
  private func setupAudioSessionChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let audioChannel = FlutterMethodChannel(name: "com.reflect.audio_session",
                                           binaryMessenger: controller.binaryMessenger)
    
    audioChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "configureAudioSession":
        self.configureAudioSession()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
