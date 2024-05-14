# IIC-Monitoring-SYSTEM

A Bash script that automatically installs and configures a webserver and adds the webserver to the iic monitoring system

## Features

- Automatically install curl , apache2 , iproute
- Quickly enable monitoring for your webserver from IRAN
- Automatically and freely monitor your severs
- ...

Supported distributions:

- Debian >= 10
- Ubuntu >= 16.04
- Fedora
- CentOS
- Oracle Linux
- Arch Linux
- Other similar distributions

## How It Works

every minute we send an http request to your server and store the response time on our database
then every hour our service will read this data and create a chart and publish it on [@iran_internet_collision](https://t.me/iran_internet_collision)
these requests are send from ArvanCloud(the only isp with lowest internet problems in iran)
so you can add your iranian or international server for the monitoring

## Usage

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ItzGlace/IIC-Monitoring/main/script.sh)
# or
wget https://raw.githubusercontent.com/ItzGlace/IIC-Monitoring/main/script.sh
bash script.sh
```

### Subcommands

```
install         Install WebServer
uninstall       Uninstall the apache WebServer
```

[MIT](https://github.com/ItzGlace/IIC-Monitoring/blob/main/LICENSE) © **[ItzGlace](https://ندارم-فعلا.برو)**

## Notice of Non-Affiliation and Disclaimer

We are not affiliated, associated, authorized, endorsed by, or in any way officially or unofficially connected with ArvanCloud or anyother Iranian ISP, or any of its subsidiaries or its affiliates.
