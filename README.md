# Proof-of-concept application deployment with Docker

The goal of this project is to provide a playground environment for Docker and show how .Net (and later also Java EE) applications can be deployed in Docker containers.

## Environment setup

1. Install necessary software:
    - [Git](https://git-scm.com/downloads) (including Git Bash on Windows)
    - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (including the Extension Pack!)
    - [Vagrant](https://www.vagrantup.com/)
2. Optionally, create a fork of this repository
3. Clone this repository (or your own fork):
    ```
    $ git clone https://github.com/bertvv/poc-docker-deployment
    ```
4. Enter the directory:
    ```
    $ cd poc-docker-deployment
    ```
5. Start the environment:
    ```
    $ vagrant up
    ```

After the VM has booted and the provisioning is finished, you should be able to surf to <http://192.168.56.12/> and see the application. It may take a minute before the application is running.

The VM also has Cockpit installed, a dashboard for viewing system services. Point your browser to <https://192.168.56.12:9090/> and log in with user name `vagrant` and password `vagrant`. You can see the running containers under the "Containers" category in the menu on the left.

## Setup details

- The application and the database each run in a separate container
- The database container is based on the Docker image provided by Microsoft (this is an evaluation version for 153 days, so not suitable for production)
- The application container is based on Microsoft's .Net application container image
- The containers communicate over an internal network with IP address 172.17.238.0/24. To the outside, only the ASP.NET core server (Kestrel), is exposed over the standard http port (80).

## Resources

Soper, N. (2016) *Hosting .Net Core on Linux with Docker - a noob's guide.* <http://blog.scottlogic.com/2016/09/05/hosting-netcore-on-linux-with-docker.html>

- Docker image with Microsoft SQLServer: <https://hub.docker.com/r/microsoft/mssql-server-linux/>
- Docker image for Microsoft ASP.NET application containers: <https://hub.docker.com/r/microsoft/dotnet/>
- Demo application: <https://github.com/WebIII/sol10MvcInDepth>
