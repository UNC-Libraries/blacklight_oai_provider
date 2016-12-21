# -*- coding: utf-8 -*-
# rubocop:disable Metrics/BlockLength

require File.join(File.dirname(__FILE__), "lib/blacklight_oai_provider/version")

Gem::Specification.new do |s|
  s.name = "blacklight_oai_provider"
  s.version = BlacklightOaiProvider::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Chris Beer", "Corey Hinshaw"]
  s.email = ["chris@cbeer.info", "hinshaw.25@osu.edu"]
  s.homepage = "http://projectblacklight.org/"
  s.summary = "Blacklight Oai Provider plugin"
  s.required_ruby_version = "~> 2.0"

  s.rubyforge_project = "blacklight"

  s.files = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 4.2'
  s.add_dependency 'blacklight', '>= 6.1'
  s.add_dependency 'oai', '~> 0.4.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'solr_wrapper', '>= 0.19'
  s.add_development_dependency 'rsolr', '~> 1.0'
  s.add_development_dependency 'blacklight-marc', '~> 6.1'
  s.add_development_dependency 'sass-rails', '~> 5.0'
  s.add_development_dependency 'jquery-rails'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rubocop', '~> 0.46.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.8'
end
