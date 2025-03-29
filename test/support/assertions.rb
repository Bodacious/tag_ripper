
module Assertions
  refine Minitest::Assertions do
    def assert_includes_subhash(superhash, subhash, message = nil)
      assert_operator superhash, :>=, subhash, message
    end
  end
end
