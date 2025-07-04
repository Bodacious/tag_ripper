guard :minitest, cli: "--verbose" do
  watch(%r{^test/(.+)_test\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch("test/test_helper.rb") { "test" }
end
