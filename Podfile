# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'SalesRecord' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SalesRecord

    pod 'RealmSwift', '~> 10.5.2'
    pod 'Firebase/Analytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'IQKeyboardManagerSwift'
    pod 'CocoaAsyncSocket'
    pod 'Printer'
    pod 'DropDown'
    pod 'Google-Mobile-Ads-SDK'
    pod 'Purchases', '3.10.1'
    pod 'SwiftKeychainWrapper'
  
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
