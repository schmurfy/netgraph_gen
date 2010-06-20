module NetGraph
  register_type('eiface') do
    add_hook('ether')
  end
  
  register_type('one2many') do
    add_hook('one')
    (0).upto(10) do |n|
      add_hook("many#{n}")
    end
    add_hook("many11", true)
  end
  
end

