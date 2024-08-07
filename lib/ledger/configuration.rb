# frozen_string_literal: true
# typed: true

module Ledger
  class << self
    extend T::Sig
    # Instantiate the Configuration singleton
    # or return it. Remember that the instance
    # has attribute readers so that we can access
    # the configured values
    sig { returns(Ledger::Configuration) }
    def configuration
      @configuration ||= Configuration.new
    end

    # This is the configure block definition.
    # The configuration method will return the
    # Configuration singleton, which is then yielded
    # to the configure block. Then it's just a matter
    # of using the attribute accessors we previously defined
    def configure
      yield(configuration)
    end
  end

  # Configuration of gem handler
  class Configuration
    # Initialize every configuration with a default.
    # Users of the gem will override these with their
    # desired values
    def initialize
      @person_class_name = "NO_PERSON_CLASS_PROVIDED"
      @tenant_class_name = "NO_TENANT_CLASS_PROVIDED"
      @running_inside_transactional_fixtures = false
    end

    attr_accessor :person_class_name, :tenant_class_name, :running_inside_transactional_fixtures
  end
end
