require 'google/protobuf'
require 'yaml'
require 'json'
require 'timeout'
require 'rbczmq'

require 'matrix_creator/version'

##
# Main module for Matrix Creator
module MatrixCreator
  # Returns a hash of settings to be used by Matrix Creator
  #
  # @return [Hash] the symbolized names object from config/matrix_creator.yml
  def self.settings
    @@_matrix_creator_config ||= JSON.parse(
      JSON.dump(YAML.load_file('config/matrix_creator.yml')),
      symbolize_names: true
    )[:matrix]
  end
end

require 'matrix_creator/everloop'
require 'matrix_creator/vision'
