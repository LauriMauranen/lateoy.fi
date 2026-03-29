resource "linode_instance" "instance1" {
    label                = "ubuntu-se-sto"
    region               = "se-sto"
    type                 = "g6-nanode-1"

    config {
        kernel       = "linode/grub2"
        label        = "My Ubuntu 24.04 LTS Disk Profile"
        root_device  = "/dev/sda"

        devices {
            sda {
                disk_label = "Ubuntu 24.04 LTS Disk"
            }
            sdb {
                disk_label = "512 MB Swap Image"
            }
        }
    }

    disk {
        label            = "Ubuntu 24.04 LTS Disk"
        size             = 25088
    }

    disk {
        label            = "512 MB Swap Image"
        size             = 512
    }
}

