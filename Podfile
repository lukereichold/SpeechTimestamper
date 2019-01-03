# Uncomment this line if you're using Swift
use_frameworks!

platform :ios, '11.0'

target 'SpeechTimestamper' do
  pod 'SwiftGRPC'
end

post_install do |installer|
  %x[ './RUNME' ]
end
