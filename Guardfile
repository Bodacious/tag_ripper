guard :minitest, cli: '--verbose' do
  watch(%r{^test/(.+)_test\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
  watch('test/test_helper.rb') { 'test' }
end

guard :rubocop, all_on_start: false, cli: '-A' do
  watch(%r{^.+\.rb$})
  watch(%r{^(config|test)/.+\.rb$})
  watch('Gemfile')
  watch('.rubocop.yml')
end
