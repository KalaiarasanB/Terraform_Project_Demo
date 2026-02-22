locals {

  primary_user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y apache2
                systemctl start apache2
                systemctl enable apache2
                echo "<h1>Primary VPC instance - ${var.primary_region}</h1>" >/var/www/html/index.html
                echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
                EOF

  secondary_user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y apache2
                systemctl start apache2
                systemctl enable apache2
                echo "<h1>Secondary VPC instance - ${var.secondary_region}</h1>" >/var/www/html/index.html
                echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
                EOF 
}
