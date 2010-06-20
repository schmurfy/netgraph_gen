module NetGraph
  class Node
    # tcpdump output :
    # 24
    # 40 0 0 12
    # 21 0 8 34525
    # 48 0 0 20
    # 21 2 0 132
    # ...
    def self.compile_bpf(pcap_string)
      bpf_prog = ""
      tmp = `tcpdump -s 8192 -ddd #{pcap_string}`.split("\n")
      
      # first line is the program length
      bpf_prog << "bpf_prog_len=#{tmp.shift}; "
      bpf_prog << "bpf_prog=["
      tmp.each do |line|
        code, jt, jf, k = line.split(' ')
        bpf_prog << " { code=#{code} jt=#{jt} jf=#{jf} k=#{k} }"
      end
      bpf_prog << " ]"
      
      bpf_prog
    end
    
    def self.bpf_node_configure_command(node_path, filter_expr, in_hook, match_hook, nomatch_hook)
      bpf_prog = compile_bpf(filter_expr)
      "msg #{node_path} setprogram { thisHook=\"#{in_hook}\" ifMatch=\"#{match_hook}\" ifNotMatch=\"#{nomatch_hook}\" #{bpf_prog} }"
    end
  end
end