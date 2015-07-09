module SpeciesHelper

  def options_for_association_conditions(association)
    if association.name == :concerns
      {:conditions => ['id IS NOT NULL'], :order => 'name ASC'}
    else
      super
    end
  end

end
