module NetGraph
  
  class Graph
    attr_accessor :nodes, :connections
    
    def initialize()
      @nodes = []
      @connections = []
      yield(self) if block_given?
    end
    
    def create_node(type, name)
      node_class = NetGraph::nodes_type[type]
      raise "node type #{type} undefined" unless node_class
      n = node_class.new(type, name)
      @nodes << n
      n
    end
    
    def connect(node, hook)
      NodeConnectionProxy.new(self, node, hook)
    end
    
    def generate_commands
      cmds = []
      # first create all the nodes and the volatile ones to the ngctl node
      # and name the nodes
      @nodes.each do |node|
        cmds << %{mkpeer #{node.type} hook#{node.id} #{node.class.temp_hook || node.class.hooks[0]} }
        cmds << %{name .:hook#{node.id} #{node.name}}
        cmds << %{rmhook . hook#{node.id}} unless node.class.temp_hook
      end
      end
      
      # link the nodes together
      @connections.each do |conn|
        cmds << %{connect #{conn.source_node.name}: #{conn.dest_node.name}: #{conn.source_hook} #{conn.dest_hook}}
      end
      
      # and remove temp links
      @nodes.select{|n| n.class.temp_hook }.each do |node|
        cmds << %{rmhook .:hook#{node.id}}
      end
      
      cmds.join("\n")
    end
  end
  
  class NodeConnectionProxy
    def initialize(graph, node, hook)
      @source_node = node
      @source_hook = hook
      @graph = graph
    end
    
    def with(node, hook)
      c = NodeConnection.new(@graph, @source_node, @source_hook, node, hook)
      @graph.connections << c
      c
    end
  end
  
  class NodeConnection
    attr_reader :source_node, :source_hook, :dest_node, :dest_hook
    
    def initialize(graph, source_node, source_hook, dest_node, dest_hook)
      @graph = graph
      @source_node = source_node
      @source_hook = source_hook
      @dest_node = dest_node
      @dest_hook = dest_hook
    end
  end
  
  class Node
    attr_accessor :name, :type, :args, :id
    
    @@next_id = 0
    
    #
    # temp_hook will be used in creation phase
    # to connect to node the the ngctl one.
    # If the node does not vanish if unlinked
    # no temp_hook are required
    #
    def self.add_hook(name, temp_hook = false)
      @hooks ||= []
      @hooks << name
      @temp_hook = name if temp_hook
      nil
    end
    
    def self.hooks
      @hooks
    end
    
    def self.temp_hook
      @temp_hook
    end
    
    def initialize(type, name)
      @type = type
      @name = name
      @id = @@next_id
      @@next_id += 1
      @temp_hook = nil
    end
  end
  
  
  def self.nodes_type
    @@nodes_type
  end
  
  def self.register_type(type_name, &block)
    @@nodes_type ||= {}    
    @@nodes_type[type_name] = Class.new(Node)
    @@nodes_type[type_name].class_eval(&block)
  end
  
  
end

