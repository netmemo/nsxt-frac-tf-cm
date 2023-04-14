terraform {
   required_providers {
      nsxt = {
         source = "vmware/nsxt"
         version = ">= 3.1.1"
      }
   }
}

#Nested for_each loop to loop over the policies then all the rules
#Then there is a for loop within the dynamic rule bloc for source, destination, services and scope to populate al lthe needed values as a list
#The for loop in the dynamic allow to extract the path for each value in the variable mappolicies. The constraint is that we CAN'T have name overlaps with the lists in the try.

resource "nsxt_policy_security_policy" "policies" {
   for_each = var.map_policies
   display_name = each.key
   category = each.value["category"]
   sequence_number = each.value["sequence_number"]

   dynamic "rule" {
      for_each = each.value["rules"]
   
      content {
         display_name = rule.value["display"]
		 source_groups = [for x in rule.value["sources"] : try(var.nsxt_policy_grp_grp[x].path)]
		 destination_groups = [for x in rule.value["destinations"] : try(var.nsxt_policy_grp_grp[x].path)]
		 action = rule.value["action"]
		 services = [for x in rule.value["services"] : try(var.nsxt_policy_svc_svc[x].path,var.nsxt_policy_svc_bltin[x].path)]
		 scope = [for x in rule.value["scope"] : try(var.nsxt_policy_grp_grp[x].path)]
		 disabled = rule.value["disabled"]
       logged = rule.value["logged"]
       direction = rule.value["direction"]
       notes = rule.value["notes"]       
      }
   }
}
