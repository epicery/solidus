# frozen_string_literal: true

class Spree::Base < ActiveRecord::Base
  include Spree::Preferences::Preferable
  include Spree::Core::Permalinks
  include Spree::RansackableAttributes

  def preferences
    read_attribute(:preferences) || self.class.preferences_coder_class.new
  end

  def initialize_preference_defaults
    if has_attribute?(:preferences)
      self.preferences = default_preferences.merge(preferences)
    end
  end

  # Only run preference initialization on models which requires it. Improves
  # performance of record initialization slightly.
  def self.preference(*args)
    # after_initialize can be called multiple times with the same symbol, it
    # will only be called once on initialization.
    serialize :preferences, preferences_coder_class
    after_initialize :initialize_preference_defaults
    super
  end

  def self.preferences_coder_class
    Hash
  end

  self.abstract_class = true

  # Provides a scope that should be included any time products
  # are fetched with the intention of displaying to the user.
  #
  # Allows individual stores to include any active record scopes or joins
  # when products are displayed.
  def self.display_includes
    where(nil)
  end
end
