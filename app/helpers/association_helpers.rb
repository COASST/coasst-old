# ActiveScaffoldAssociations
# Pulled from: http://groups.google.com/group/activescaffold/browse_thread/thread/36b9aa197b3aa332
module ActiveScaffold
  module Helpers
    module Associations
      # Provides a way to honor the :conditions on an association
      # while searching the association's klass
      def association_options_find(association, conditions = nil)
        find_conditions = conditions
        find_order = nil
        if (conditions && conditions.length > 1)
          find_conditions = conditions[:conditions] || nil
          find_order = conditions[:order] || nil
        end
        association.klass.find(:all, :conditions =>
          controller.send(:merge_conditions, find_conditions,
          association.options[:conditions]), :order => find_order)
      end

      def association_options_count(association, conditions = nil)
        find_conditions = conditions
        if (conditions && conditions.length > 1)
          find_conditions = conditions[:conditions] || nil
        end
        association.klass.count(:all, :conditions =>
          controller.send(:merge_conditions, find_conditions,
          association.options[:conditions]))
      end

      # returns options for the given association as a collection of
      #[id, label] pairs intended for the +options_for_select+ helper.
      def options_for_association(association)
        available_records = association_options_find(association,
          options_for_association_conditions(association))
        available_records ||= []
        #available_records.sort{|a,b| a.to_label <=>
        #b.to_label}.collect { |model| [ model.to_label, model.id ] }
        available_records.collect { |model| [ model.to_label, model.id ] }
      end

      def options_for_association_count(association)
        association_options_count(association,
          options_for_association_conditions(association))
      end

      # A useful override for customizing the records present in an association dropdown.
      # Should work in both the subform and form_ui=>:select modes.
      # Check association.name to specialize the conditions per- column.
      def options_for_association_conditions(association)
        return nil if association.options[:through]
        case association.macro
          when :has_one, :has_many
            # Find only orphaned objects
            "#{association.primary_key_name} IS NULL"
          when :belongs_to, :has_and_belongs_to_many
            # Find all
            nil
        end
      end
    end
  end
end
