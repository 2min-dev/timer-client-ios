# Uncomment the next line to define a global platform for your project
  platform :ios, '10.0'

target 'timer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings! # Ignore all warnings

  # Pods for timer
  # Firebase
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  pod 'Firebase/Analytics'
  
  # Common Libraries
  pod 'JSReorderableCollectionView', '~> 1.0.6'

  # RxSwift
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources', '~> 4.0'
  pod 'ReactorKit'
  pod 'SnapKit', '~> 4.0.0'

  # Alamofire
  pod 'Alamofire', '~> 5.0.0-rc.2'

  # Realm
  pod 'RealmSwift', '~> 3.17.3'
  
  # SwiftLint
  pod 'SwiftLint'
  
  # Log
  pod 'SwiftyBeaver'
  
  target 'timerTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxTest', '~> 5'
  end
end
