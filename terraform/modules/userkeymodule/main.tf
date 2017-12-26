# SSH public keys temlate
data "template_file" "ssh_public_keys" {
  count = "${length(var.users_public_keys)}"

  template = "$${trimspace(format("%s:%s",user,file(sshkey)))}"

  vars {
    user   = "${element(keys(var.users_public_keys),count.index)}"
    sshkey = "${element(values(var.users_public_keys),count.index)}"
  }
}
