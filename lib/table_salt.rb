require "table_salt/version"

module TableSalt

  extend ActiveSupport::Concern

  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  include ActiveModel::Validations

  included do

    #attribute_method_prefix '', 'clear_'
    attribute_method_suffix '='

    attr_accessor :attributes

  end

  def initialize( attributes={} )
    return unless attributes
    @attributes = attributes.stringify_keys

    multi_parameter_attributes, attributes = attributes.partition { |k,v| k =~ /^(.*)\((\di)\)$/ }

    attributes.each do |name, value|
      send "#{name}=", value
    end

    assign_multiparameter_attributes( multi_parameter_attributes )
  end

  def persisted?
    false
  end

  def read_attribute_for_validation( key )
    attributes[key.to_s]
  end

  def attribute( attr )
    attributes[attr.to_s]
  end
  private :attribute

  def clear_attribute( attr )
    attributes[attr.to_s] = nil
  end
  private :clear_attribute

  def attribute=( attr, val )
    attributes[attr.to_s] = val
  end
  private :attribute=

  module ClassMethods

    def human_attribute_name( attr )
      name = I18n.translate( "activerecord.attributes.#{self.name.underscore}.#{attr}" )

      name.include?( 'translation missing: ' ) ?
        attr.to_s.humanize :
        name
    end

  end

  module MultiparameterAssignment

    # Instantiates objects for all attribute classes that needs more than one constructor parameter. This is done
    # by calling new on the column type or aggregation type (through composed_of) object with these parameters.
    # So having the pairs written_on(1) = "2004", written_on(2) = "6", written_on(3) = "24", will instantiate
    # written_on (a date type) with Date.new("2004", "6", "24"). You can also specify a typecast character in the
    # parentheses to have the parameters typecasted before they're used in the constructor. Use i for Fixnum,
    # f for Float, s for String, and a for Array. If all the values for a given attribute are empty, the
    # attribute will be set to nil.
    def assign_multiparameter_attributes( pairs )
      collect_param_parts( pairs ).each do |attribute, parts|
        parts = parts.sort { |a,b| a.first <=> b.first }.map { |k,v| v.to_i }
        instance = instantiate_time_object( attribute, parts )
        send "#{attribute}=", instance
      end
    end

    def collect_param_parts( pairs )
      datetime_params = {}

      pairs.each do |key, value|
        attribute_name, date_part = key.match( /^(.*)\((\di)\)$/ )[1..2]

        if attribute_name
          datetime_params[attribute_name] ||= {}
          datetime_params[attribute_name][date_part] = value
        end
      end

      datetime_params
    end

    def instantiate_time_object( name, values )
      DateTime.new *values # this will throw an exception if the date is not valid (Time#local does not)
      Time.zone.local *values
    rescue
      self.errors.add name, 'invalid date or time'
      nil
    end

  end #module MultiparameterAssignment

  include MultiparameterAssignment

end
