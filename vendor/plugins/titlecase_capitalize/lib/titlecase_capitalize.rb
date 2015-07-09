class String

  def titlecase()
    ignore_list = %w{of etc and by the for on is at to but nor or a via}
    capitalize_all_ex(ignore_list)
  end

  def titlecase!()
    ignore_list = %w{of etc and by the for on is at to but nor or a via}
    capitalize_all_ex!(ignore_list)
  end

  def capitalize_all(force_downcase = true)
    ignore_list = %w{}
    capitalize_all_ex(ignore_list, force_downcase)
  end

  def capitalize_all!(force_downcase = true)
    ignore_list = %w{}
    capitalize_all_ex!(ignore_list, force_downcase)
  end

  def capitalize_all_ex(ignore_list, force_downcase = true)
    # if force_downcase is true then the 
    # string is, um, downcased first :-)
    if force_downcase
      self.downcase.gsub(/[\w\']+/){ |w| 
        ignore_list.include?(w) ? w : w.capitalize  
      }
    else
      self.gsub(/[\w\']+/){ |w| 
        ignore_list.include?(w) ? w : w.capitalize  
      }
    end
  end

  def capitalize_all_ex!(ignore_list, force_downcase = true)
    if force_downcase
      self.replace(self.downcase.gsub(/[\w\']+/){ |w| 
        ignore_list.include?(w) ? w : w.capitalize  
      })
    else
      self.replace(self.gsub(/[\w\']+/){ |w| 
        ignore_list.include?(w) ? w : w.capitalize  
      })
    end
  end
end

