# ELK Stack - Deployment
Here we will provide all the steps needed to implement an ELK stack.

## How to Implement ELK Stack
### Automatically
This branch contains:
*   terraform/
    *   Terraform file to provision a VM to use as ELK
*   ansible/
    *   Ansible files needed to implement ELK

### Manually [for CentOS7]
1-  Need to deploy CentOS7 server with accessible IP & connection to internet to get repos
2-  Install Repo for ElasticSearch 7 by running
        cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
        [elasticsearch-7.x]
        name=Elasticsearch repository for 7.x packages
        baseurl=https://artifacts.elastic.co/packages/7.x/yum
        gpgcheck=1
        gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
        enabled=1
        autorefresh=1
        type=rpm-md
        EOF
3-  Install GPG Key
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
4-  Clean & recreate cache
    yum clean all
    yum makecache
5-  Need to install the following packages:
    1-  java-1.8.0-openjdk
    2-  elasticsearch
    3-  kibana
    4-  logstash
    5-  filebeat
5-  Create folder /var/log/kibana
    mkdir /var/log/kibana && chmod 777 /var/log/kibana
6-  Create Kibana configuration file [/etc/kibana/kibana.yml]
    server.host: "0.0.0.0"
    server.name: "kibana.example.com"
    elasticsearch.hosts: ["http://localhost:9200"]
    logging.dest: /var/log/kibana/kibana.log
    EOL
7-  Create Logstash configuration file [/etc/logstash/conf.d/logstash.conf] with the following configuration
    input {
        beats {
            port => 5044
            ssl => false

        }
    }
    filter {
    if [type] == "syslog" {
        grok {
            match => { "message" => "%{SYSLOGLINE}" }
        }

        date {
            match => [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
        }
    }

    }
    output {
        elasticsearch {
            hosts => localhost
                index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        }
        stdout {
            codec => rubydebug
        }
    }
7-  Set Kibana & Logstash Services Started
    systemctl start logstash
    systemctl enable logstash
    systemctl start kibana
    systemctl enable kibana
8-  Open Firewall Ports
    firewall-cmd --add-port=5601/tcp --permanent
    firewall-cmd --reload
9-  Access it via http://server_ip:5601


## How to Test
You can access current ELK stack deployment by accessing http://10.26.48.128:5601. There is no credentials needed to access it.

## Contact

In case you need to contact me, you can do so via:
* Skype: jonathan.tissot
