# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'GithubBrowser' do
  use_frameworks!

  # Pods for GithubBrowser
  pod 'SwiftLint'
  pod 'SwiftGen', '6.4.0'
  pod 'BartyCrouch', '4.5.0'
  pod 'CocoaLumberjack/Swift', '3.7.2'
  pod 'Swinject', '2.6.0'
  pod 'SwinjectStoryboard', '2.2.0'
  pod 'InjectPropertyWrapper'
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'RxSwiftExt', '~> 6.0'
  pod 'RxDataSources', '~> 5.0'
  pod 'Moya/RxSwift', '15.0.0'
  pod 'RxFlow', '~> 2.12'
  pod 'Kingfisher'

  target 'GithubBrowserTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble', '~> 9.2.1'
    pod 'Quick', '~> 3.1'
    pod 'MockingbirdFramework', '~> 0.18'
    pod 'RxBlocking', '~> 6.0'
    pod 'RxTest', '~> 6.0'
    pod 'ViewControllerPresentationSpy', '~> 5.0'
  end

  target 'GithubBrowserUITests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble', '~> 9.0'
  end

end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end


