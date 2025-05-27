# ---------------------------------------------
#    Main Module Output return variables
# ---------------------------------------------

output "all_node_ssh_commands" {
  value = [
    for i in module.node :
    "ssh -i ${var.ssh_private_key_path} ubuntu@${i.public_ip}"
  ]
}

output "all_node_http_urls" {
  value = [
    for i in module.node :
    "http://${i.public_dns}"
  ]
}

