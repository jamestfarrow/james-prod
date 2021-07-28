#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo chkconfig httpd on
sudo service httpd start
echo "<h1>James-Prod-Web-Project</h1>
<h2>Deployed via Terraform</h2>" | sudo tee /var/www/html/index.html