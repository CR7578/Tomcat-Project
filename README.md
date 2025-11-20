# Vagrant Tomcat Project

This project demonstrates a Java web application packaged for Apache Tomcat and provisioned inside a Vagrant VM. The repository contains the application source code (Maven-based), web resources, Spring configuration, database scripts, and Vagrant provisioning scripts that install and configure Tomcat, MySQL, RabbitMQ and other dependencies on a development VM.

---

**Install prerequisites on your host machine:**

Vagrant (2.x recommended)
VirtualBox or another Vagrant provider
On Windows, use Git Bash, WSL, or an elevated shell

**How to run this project**

- Clone the repo:

```bash
git clone https://github.com/CR7578/Vagrant-tomcat-project.git
```

- change directory

```bash
cd Vagrant-Tomcat-project/vagrant
```

- Bring up the VM (provisioning will run the shell scripts under `vagrant/`):

```bash
vagrant up
```

**Access the application**
- Open `http://web01` or `192.168.56.11` in the browser.

- default login credentials
    
    username - admin
  
    password - cr7578
    
 
**Note :**  if you have changed any ip address in `Vagrantfile` for web01 nginx server, use the modified ip address.

# Output Screenshots

![Tomcat-login](/assets/tomcat-login.png)
![Tomcat-dashboard](/assets/tomcat-dashboard.png)
![Tomcat-memcached](/assets/tomcat-memcached.png)
![Tomcat-memcached](/assets/tomcat-memcached2.png)
![Tomcat-rabbitmq](/assets/tomcat-rabbitmq.png)
