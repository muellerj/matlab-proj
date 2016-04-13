function [inportlist outportlist] = find_ports(block_handle)

  ports = get_param(block_handle, 'PortHandles');

  inportlist = ports.Inport;
  outportlist = ports.Outport;

end
