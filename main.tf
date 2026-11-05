# Obtener info del subnet para sacar el VCN ID
data "oci_core_subnet" "web" {
  subnet_id = var.subnet_ocid
}

# Crear Network Security Group para puerto 80
resource "oci_core_network_security_group" "web_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_subnet.web.vcn_id
  display_name   = "web-nsg-http"
}

# Regla que permite trafico HTTP entrante (puerto 80)
resource "oci_core_network_security_group_security_rule" "allow_http" {
  network_security_group_id = oci_core_network_security_group.web_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Regla que permite trafico SSH entrante (puerto 22)
resource "oci_core_network_security_group_security_rule" "allow_ssh" {
  network_security_group_id = oci_core_network_security_group.web_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# Regla que permite todo el trafico saliente
resource "oci_core_network_security_group_security_rule" "allow_egress" {
  network_security_group_id = oci_core_network_security_group.web_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_instance" "ubuntu-vm" {
  compartment_id      = var.compartment_ocid
  display_name        = "ubuntu-web-estatica"
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E2.2"

  source_details {
    source_type = "image"
    source_id   = trimspace(var.ubuntu_2404_image_ocid)
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "vnic-ubuntu-web"
    hostname_label   = "ubuntuwebestatica"
    nsg_ids          = [oci_core_network_security_group.web_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = trimspace(var.ssh_public_key)
    user_data           = filebase64("${path.module}/userdata.sh")
  }

  lifecycle {
    # Cloud-init solo se ejecuta al crear la VM. Las versiones web se publican por SSH.
    ignore_changes = [metadata["user_data"]]
  }
}

output "public_ip" {
  value       = oci_core_instance.ubuntu-vm.public_ip
  description = "IP Publica de servidor web"
}
