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


  register_type('bpf') do
    add_hook('in')
    add_hook("match")
    add_hook("nomatch")
    
    add_hook("dummy", true) # useless, just for init phase
    
    after_create_command do |node|
      bpf_node_configure_command("#{node.name}:", node.args[:filter], 'in', 'match', 'nomatch')
    end
  end
end

