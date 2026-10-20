# JaerimHomp.xcodeproj 를 다시 만드는 스크립트
#   gem install xcodeproj
#   ruby scripts/generate_project.rb
require 'fileutils'
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'JaerimHomp.xcodeproj')
DEPLOYMENT_TARGET = '17.0'

FileUtils.rm_rf(PROJECT_PATH)
project = Xcodeproj::Project.new(PROJECT_PATH)

project.build_configurations.each do |config|
  config.build_settings['BASE_BUNDLE_ID'] = 'com.sleepyapple.jaerimhomp'
  config.build_settings['APP_GROUP_ID'] = 'group.$(BASE_BUNDLE_ID)'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
end

app = project.new_target(:application, 'JaerimHomp', :ios, DEPLOYMENT_TARGET)
ext = project.new_target(:app_extension, 'ShareExtension', :ios, DEPLOYMENT_TARGET)

# xcodeproj 가 SDK 버전이 박힌 Foundation.framework 를 넣는데, Swift 는 자동 링크하므로 뺀다
[app, ext].each { |t| t.frameworks_build_phase.files.to_a.each(&:remove_from_project) }
project.frameworks_group.children.to_a.each(&:remove_from_project)

shared_group = project.main_group.new_group('Shared', 'Shared')
shared_refs = %w[SharedItem.swift SharedStore.swift].map { |f| shared_group.new_file(f) }

app_group = project.main_group.new_group('JaerimHomp', 'JaerimHomp')
app_refs = %w[JaerimHompApp.swift Schedule.swift ScheduleView.swift SharedListView.swift]
           .map { |f| app_group.new_file(f) }
assets_ref = app_group.new_file('Assets.xcassets')
%w[Info.plist JaerimHomp.entitlements].each { |f| app_group.new_file(f) }

ext_group = project.main_group.new_group('ShareExtension', 'ShareExtension')
ext_refs = [ext_group.new_file('ShareViewController.swift')]
%w[Info.plist ShareExtension.entitlements].each { |f| ext_group.new_file(f) }

app.add_file_references(app_refs + shared_refs)
app.add_resources([assets_ref])
ext.add_file_references(ext_refs + shared_refs)

# 공유 확장을 앱 안에 넣기
app.add_dependency(ext)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(ext.product_reference).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

common = {
  'SWIFT_VERSION' => '5.0',
  'TARGETED_DEVICE_FAMILY' => '1', # 아이폰 전용
  'GENERATE_INFOPLIST_FILE' => 'YES',
  'CODE_SIGN_STYLE' => 'Automatic',
  'DEVELOPMENT_TEAM' => '',
  'MARKETING_VERSION' => '1.0',
  'CURRENT_PROJECT_VERSION' => '1',
  'PRODUCT_NAME' => '$(TARGET_NAME)',
  'INFOPLIST_KEY_CFBundleDisplayName' => "Jaerim's homp",
}

app.build_configurations.each do |config|
  config.build_settings.merge!(common).merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => '$(BASE_BUNDLE_ID)',
    'INFOPLIST_FILE' => 'JaerimHomp/Info.plist',
    'CODE_SIGN_ENTITLEMENTS' => 'JaerimHomp/JaerimHomp.entitlements',
    'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
    'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
    'INFOPLIST_KEY_UILaunchScreen_Generation' => 'YES',
    'INFOPLIST_KEY_UIApplicationSceneManifest_Generation' => 'YES',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations' => 'UIInterfaceOrientationPortrait',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks',
    'ENABLE_PREVIEWS' => 'YES',
  )
end

ext.build_configurations.each do |config|
  config.build_settings.merge!(common).merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => '$(BASE_BUNDLE_ID).ShareExtension',
    'INFOPLIST_FILE' => 'ShareExtension/Info.plist',
    'CODE_SIGN_ENTITLEMENTS' => 'ShareExtension/ShareExtension.entitlements',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks',
    'SKIP_INSTALL' => 'YES',
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
  )
end

project.save

# 실행용 스킴
scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app, nil, launch_target: true)
scheme.save_as(PROJECT_PATH, 'JaerimHomp', true)

puts "Generated #{PROJECT_PATH}"
