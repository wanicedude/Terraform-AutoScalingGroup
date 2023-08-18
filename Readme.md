# Business Case: A company needs to host a web application that is highly available and can automatically scale based on demand. &nbsp; 



# Solution  &nbsp; 

>**Steps:**
1. **Generate a personalized VPC by establishing two public subnets, setting up a route table, and attaching an Internet Gateway to enable outbound online connectivity. Additionally, configure a security group that permits incoming traffic from the internet.** &nbsp; 

2. **Deploy an Auto Scaling group that spans across two subnets within your custom VPC. Attach the specified security group to this Auto Scaling group. Additionally, integrate a script into your user data that initiates the launch of an Apache web server.**

3. **Check the main.tf file and var.tf file for code**