output "ssh-keys-string" {
  value = "${join("\n",data.template_file.ssh_public_keys.*.rendered)}"
}
