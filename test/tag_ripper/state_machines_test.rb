# frozen_string_literal: true

require "test_helper"
module TagRipper
  class StateMachinesTest < Minitest::Test
    def test_state_machine_defines_state_macro_on_class
      Class.new do
        include TagRipper::StateMachines

        state_machine do |sm|
          sm.state :foo
          sm.state :bar
        end
      end
    end

    def test_state_machine_adds_states_to_class
      test_class = Class.new do
        include TagRipper::StateMachines

        state_machine do
          state :foo
          state :bar
        end
      end
      state_names = test_class.state_names

      assert_includes state_names, :foo
      assert_includes state_names, :bar
    end

    def test_state_machine_adds_event_transitions_to_class
      test_class = Class.new do
        include TagRipper::StateMachines

        attr_accessor :status

        state_machine do
          state :foo
          state :bar

          event :do_bar do
            transitions from: :foo, to: :bar
          end
        end
      end

      test_instance = test_class.new

      assert_predicate test_instance, :foo?
      test_instance.respond_to?(:do_bar)
      test_instance.do_bar!

      assert_predicate test_instance, :bar?
    end
  end
end
