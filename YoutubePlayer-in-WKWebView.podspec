Pod::Spec.new do |s|
  s.name              = 'YoutubePlayer-in-WKWebView'
  s.version           = '0.3.4'
  s.summary           = 'YoutubePlayer using WKWebView'

  s.description       = 'Helper library for iOS developers that want to embed YouTube videos in
                         their iOS apps with the iframe player API in WKWebView.'

  s.homepage           = 'https://github.com/hmhv/YoutubePlayer-in-WKWebView'
  s.license            = {
                            :type => 'Apache',
                            :text => <<-LICENSE
                              Copyright 2014 Google Inc. All rights reserved.

                              Licensed under the Apache License, Version 2.0 (the 'License');
                              you may not use this file except in compliance with the License.
                              You may obtain a copy of the License at

                              http://www.apache.org/licenses/LICENSE-2.0

                              Unless required by applicable law or agreed to in writing, software
                              distributed under the License is distributed on an 'AS IS' BASIS,
                              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                              See the License for the specific language governing permissions and
                              limitations under the License.
                            LICENSE
                         }
  s.author             = { 'hmhv' => 'admin@hmhv.info' }
  s.source             = { :git => 'https://github.com/hmhv/YoutubePlayer-in-WKWebView.git', :tag => s.version }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'WKYTPlayerView'
  s.resources = 'WKYTPlayerView/WKYTPlayerView.bundle'

end
