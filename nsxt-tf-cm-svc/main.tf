terraform {
   required_providers {
      nsxt = {
         source = "vmware/nsxt"
         version = ">= 3.1.1"
      }
   }
}

resource "nsxt_policy_service" "svc" {
   for_each = var.map_svc
   #key = service name
   display_name = each.key
   
   dynamic "l4_port_set_entry" {
      #each.value = map of TCP,UDP or IP list where l4_port_set_entry.key will be TCP or UDP
      #the for_each contain a for loop with filter to create the l4_port_set_entry only if there is a list with TCP or UDP as name
      for_each = { for key,val in each.value : key => val if key == "TCP" || key == "UDP" }
	  content {
	     display_name = "${l4_port_set_entry.key}_${each.key}"
	     protocol = l4_port_set_entry.key
	     destination_ports = l4_port_set_entry.value
      }
   }

   dynamic "ip_protocol_entry" {
      #each.value = map of TCP,UDP or IP list
      #the for_each contain a for loop with filter to create the ip_protocol_entry only if there is a list with a IP as name
      for_each = { for key,val in each.value : key => val if key == "IP" }
	  content {
	     #[0] because the ip protocol will have a single IP protocol value in the set and the protocol attribut expect a number not a set
	     protocol = ip_protocol_entry.value[0]
      }
   }
}
