lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compare_with_wikidata/version'

Gem::Specification.new do |spec|
  spec.name          = 'compare_with_wikidata'
  spec.version       = CompareWithWikidata::VERSION
  spec.authors       = ['EveryPolitician']
  spec.email         = ['team@everypolitician.org']

  spec.summary       = 'Compare the results of a Wikidata SPARQL query with a CSV file'
  spec.homepage      = 'https://github.com/everypolitician/compare_morph_to_wikidata'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'daff', '>= 1.3.26'
  spec.add_runtime_dependency 'mediawiki_api', '~> 0.7'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.0.0'
end
