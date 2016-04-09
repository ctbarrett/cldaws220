# Homework / Lab Exercises - Week 8

## Working with Load Balancers and Auto Scaling

### Lab 1 - ELB: Create and List Elastic Load-Balancer (aws cli)

```bash
$ aws elb create-load-balancer --load-balancer-name cb99-elb-test --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=4567" --subnets subnet-9a1023ff subnet-0494fd5d subnet-6f540518 --security-groups sg-7c7e361b
{
    "DNSName": "cb99-elb-test-328870456.us-west-2.elb.amazonaws.com"
}

$ aws elb describe-load-balancers
{
    "LoadBalancerDescriptions": [
        {
            "Subnets": [
                "subnet-0494fd5d",
                "subnet-6f540518",
                "subnet-9a1023ff"
            ],
            "CanonicalHostedZoneNameID": "Z33MTJ483KN6FU",
            "CanonicalHostedZoneName": "cb99-elb-test-328870456.us-west-2.elb.amazonaws.com",
            "ListenerDescriptions": [
                {
                    "Listener": {
                        "InstancePort": 4567,
                        "LoadBalancerPort": 80,
                        "Protocol": "HTTP",
                        "InstanceProtocol": "HTTP"
                    },
                    "PolicyNames": []
                }
            ],
            "HealthCheck": {
                "HealthyThreshold": 10,
                "Interval": 30,
                "Target": "TCP:4567",
                "Timeout": 5,
                "UnhealthyThreshold": 2
            },
            "VPCId": "vpc-451d3220",
            "BackendServerDescriptions": [],
            "Instances": [],
            "DNSName": "cb99-elb-test-328870456.us-west-2.elb.amazonaws.com",
            "SecurityGroups": [
                "sg-7c7e361b"
            ],
            "Policies": {
                "LBCookieStickinessPolicies": [],
                "AppCookieStickinessPolicies": [],
                "OtherPolicies": []
            },
            "LoadBalancerName": "cb99-elb-test",
            "CreatedTime": "2016-04-09T03:04:55.230Z",
            "AvailabilityZones": [
                "us-west-2a",
                "us-west-2b",
                "us-west-2c"
            ],
            "Scheme": "internet-facing",
            "SourceSecurityGroup": {
                "OwnerAlias": "907677783442",
                "GroupName": "cb99 ELB test"
            }
        }
    ]
}
```

### Lab 2 - ELB: Register instances

```bash
# Start some ec2 instances
$ aws ec2 run-instances --image-id ami-31d63951 --key-name cb99-w2 --security-group-ids sg-967e36f1 --instance-type t2.micro --subnet-id subnet-9a1023ff

{
    "OwnerId": "907677783442",
    "ReservationId": "r-0cd4ddc9",
    "Groups": [],
    "Instances": [
        {
            "Monitoring": {
                "State": "disabled"
            },
            "PublicDnsName": "",
            "RootDeviceType": "ebs",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "EbsOptimized": false,
            "LaunchTime": "2016-04-09T02:50:24.000Z",
            "PrivateIpAddress": "172.31.18.6",
            "ProductCodes": [],
            "VpcId": "vpc-451d3220",
            "StateTransitionReason": "",
            "InstanceId": "i-538a8c94",
            "ImageId": "ami-31d63951",
            "PrivateDnsName": "ip-172-31-18-6.us-west-2.compute.internal",
            "KeyName": "cb99-w2",
            "SecurityGroups": [
                {
                    "GroupName": "cb99 web server test",
                    "GroupId": "sg-967e36f1"
                }
            ],
            "ClientToken": "",
            "SubnetId": "subnet-9a1023ff",
            "InstanceType": "t2.micro",
            "NetworkInterfaces": [
                {
                    "Status": "in-use",
                    "MacAddress": "02:1e:3f:05:e5:69",
                    "SourceDestCheck": true,
                    "VpcId": "vpc-451d3220",
                    "Description": "",
                    "NetworkInterfaceId": "eni-a3432dd8",
                    "PrivateIpAddresses": [
                        {
                            "PrivateDnsName": "ip-172-31-18-6.us-west-2.compute.internal",
                            "Primary": true,
                            "PrivateIpAddress": "172.31.18.6"
                        }
                    ],
                    "PrivateDnsName": "ip-172-31-18-6.us-west-2.compute.internal",
                    "Attachment": {
                        "Status": "attaching",
                        "DeviceIndex": 0,
                        "DeleteOnTermination": true,
                        "AttachmentId": "eni-attach-dfed3828",
                        "AttachTime": "2016-04-09T02:50:24.000Z"
                    },
                    "Groups": [
                        {
                            "GroupName": "cb99 web server test",
                            "GroupId": "sg-967e36f1"
                        }
                    ],
                    "SubnetId": "subnet-9a1023ff",
                    "OwnerId": "907677783442",
                    "PrivateIpAddress": "172.31.18.6"
                }
            ],
            "SourceDestCheck": true,
            "Placement": {
                "Tenancy": "default",
                "GroupName": "",
                "AvailabilityZone": "us-west-2b"
            },
            "Hypervisor": "xen",
            "BlockDeviceMappings": [],
            "Architecture": "x86_64",
            "StateReason": {
                "Message": "pending",
                "Code": "pending"
            },
            "RootDeviceName": "/dev/xvda",
            "VirtualizationType": "hvm",
            "AmiLaunchIndex": 0
        }
    ]
}

# repeated the same with different subnets for one instance in each AZ...

# update the health check on the ELB to check the ping page
$ aws elb configure-health-check --load-balancer-name cb99-elb-test --health-check "Target=HTTP:4567/png,Interval=30,Timeout=15,UnhealthyThreshold=2,HealthyThreshold=2"
{
    "HealthCheck": {
        "HealthyThreshold": 3,
        "Interval": 30,
        "Target": "HTTP:4567/png",
        "Timeout": 15,
        "UnhealthyThreshold": 2
    }
}

# then enable cross-az load-balancing
$ aws elb modify-load-balancer-attributes --load-balancer-name cb99-elb-test --load-balancer-attributes '{"CrossZoneLoadBalancing": {"Enabled": true}}'
{
    "LoadBalancerAttributes": {
        "CrossZoneLoadBalancing": {
            "Enabled": true
        }
    },
    "LoadBalancerName": "cb99-elb-test"
}

# register the instances with the ELB
$ aws elb register-instances-with-load-balancer --load-balancer-name cb99-elb-test --instances i-667524be i-538a8c94 i-084056d2
{
    "Instances": [
        {
            "InstanceId": "i-538a8c94"
        },
        {
            "InstanceId": "i-667524be"
        },
        {
            "InstanceId": "i-084056d2"
        }
    ]
}

# double-check the load balancer config
$ aws elb describe-load-balancers
{
    "LoadBalancerDescriptions": [
        {
            "Subnets": [
                "subnet-0494fd5d",
                "subnet-6f540518",
                "subnet-9a1023ff"
            ],
            "CanonicalHostedZoneNameID": "Z33MTJ483KN6FU",
            "CanonicalHostedZoneName": "cb99-elb-test-328870456.us-west-2.elb.amazonaws.com",
            "ListenerDescriptions": [
                {
                    "Listener": {
                        "InstancePort": 4567,
                        "LoadBalancerPort": 80,
                        "Protocol": "HTTP",
                        "InstanceProtocol": "HTTP"
                    },
                    "PolicyNames": []
                }
            ],
            "HealthCheck": {
                "HealthyThreshold": 2,
                "Interval": 30,
                "Target": "HTTP:4567/png",
                "Timeout": 15,
                "UnhealthyThreshold": 2
            },
            "VPCId": "vpc-451d3220",
            "BackendServerDescriptions": [],
            "Instances": [
                {
                    "InstanceId": "i-667524be"
                },
                {
                    "InstanceId": "i-084056d2"
                },
                {
                    "InstanceId": "i-538a8c94"
                }
            ],
            "DNSName": "cb99-elb-test-328870456.us-west-2.elb.amazonaws.com",
            "SecurityGroups": [
                "sg-7c7e361b"
            ],
            "Policies": {
                "LBCookieStickinessPolicies": [],
                "AppCookieStickinessPolicies": [],
                "OtherPolicies": []
            },
            "LoadBalancerName": "cb99-elb-test",
            "CreatedTime": "2016-04-09T03:04:55.230Z",
            "AvailabilityZones": [
                "us-west-2a",
                "us-west-2b",
                "us-west-2c"
            ],
            "Scheme": "internet-facing",
            "SourceSecurityGroup": {
                "OwnerAlias": "907677783442",
                "GroupName": "cb99 ELB test"
            }
        }
    ]
}

# and test that incoming requests are distributed across all 3 servers
$ while : ; do curl http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com/; sleep 1; done
hello from ip-172-31-9-51
hello from ip-172-31-46-219
hello from ip-172-31-18-6
hello from ip-172-31-9-51
hello from ip-172-31-46-219
hello from ip-172-31-18-6
hello from ip-172-31-9-51
^C
$
```

### Lab 3 - ELB: Health check failure

```bash
# Start monitor loop
$ while : ; do echo "$(date '+%H:%M:%S:') $(curl -s http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com/)"; sleep 1; done
21:15:10: hello from ip-172-31-46-219
21:15:11: hello from ip-172-31-18-6
21:15:13: hello from ip-172-31-9-51
21:15:14: hello from ip-172-31-46-219
21:15:15: hello from ip-172-31-18-6
21:15:16: hello from ip-172-31-9-51
...

# terminal 2 - kill the service
[ec2-user@ip-172-31-18-6 ~]$ pgrep -fl ruby
2213 ruby -rsinatra -e set :bind, "0.0.0.0"; get "/" do; sleep params[:sleep].to_i if params[:sleep]; "hello from #{`hostname`}"; end; get "/png" do; "healthy\n"; end
[ec2-user@ip-172-31-18-6 ~]$ sudo pkill -9 ruby

# terminal 1 - no more replies from 172.31.18.6
...
21:15:17: hello from ip-172-31-46-219
21:15:18: hello from ip-172-31-9-51
21:15:19: hello from ip-172-31-46-219
21:15:20: hello from ip-172-31-9-51
21:15:21: hello from ip-172-31-46-219
21:15:22: hello from ip-172-31-9-51
21:15:23: hello from ip-172-31-46-219
21:15:24: hello from ip-172-31-9-51
21:15:26: hello from ip-172-31-46-219
21:15:27: hello from ip-172-31-9-51
21:15:28: hello from ip-172-31-46-219
21:15:29: hello from ip-172-31-9-51
21:15:30: hello from ip-172-31-46-219
21:15:31: hello from ip-172-31-9-51
21:15:32: hello from ip-172-31-46-219
21:15:33: hello from ip-172-31-9-51

# terminal 2 - restart the service
[ec2-user@ip-172-31-18-6 ~]$ sudo service mini-sinatra start
Starting mini-sinatra: [ec2-user@ip-172-31-18-6 ~]$ [2016-04-09 04:15:31] INFO  WEBrick 1.3.1
[2016-04-09 04:15:31] INFO  ruby 2.0.0 (2015-12-16) [x86_64-linux]
== Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from WEBrick
[2016-04-09 04:15:31] INFO  WEBrick::HTTPServer#start: pid=2985 port=4567
73.140.153.44 - - [09/Apr/2016:04:15:34 +0000] "GET / HTTP/1.1" 200 26 0.0042
ip-172-31-33-77.us-west-2.compute.internal - - [09/Apr/2016:04:15:34 UTC] "GET / HTTP/1.1" 200 26
- -> /
73.140.153.44 - - [09/Apr/2016:04:15:37 +0000] "GET / HTTP/1.1" 200 26 0.0021
ip-172-31-33-77.us-west-2.compute.internal - - [09/Apr/2016:04:15:37 UTC] "GET / HTTP/1.1" 200 26
- -> /
172.31.31.54 - - [09/Apr/2016:04:15:38 +0000] "GET /png HTTP/1.1" 200 8 0.0005
ip-172-31-31-54.us-west-2.compute.internal - - [09/Apr/2016:04:15:38 UTC] "GET /png HTTP/1.1" 200 8
- -> /png
172.31.0.83 - - [09/Apr/2016:04:15:38 +0000] "GET /png HTTP/1.1" 200 8 0.0003
ip-172-31-0-83.us-west-2.compute.internal - - [09/Apr/2016:04:15:38 UTC] "GET /png HTTP/1.1" 200 8
- -> /png
172.31.33.77 - - [09/Apr/2016:04:15:38 +0000] "GET /png HTTP/1.1" 200 8 0.0003
ip-172-31-33-77.us-west-2.compute.internal - - [09/Apr/2016:04:15:38 UTC] "GET /png HTTP/1.1" 200 8
- -> /png

# terminal 1 - responses start coming in from 172.31.18.6 again
...
21:15:34: hello from ip-172-31-18-6
21:15:35: hello from ip-172-31-46-219
21:15:36: hello from ip-172-31-9-51
21:15:37: hello from ip-172-31-18-6
21:15:38: hello from ip-172-31-46-219
21:15:40: hello from ip-172-31-9-51
^C

```

### Lab 4 - ELB: Connection draining

```bash
# Ensure ELB only has one instance registered
$ aws elb deregister-instances-from-load-balancer --load-balancer-name cb99-elb-test --instances i-667524be i-084056d2
{
    "Instances": [
        {
            "InstanceId": "i-538a8c94"
        }
    ]
}

# Start long-running query/session
$ curl --include 'http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com?sleep=20'
...

# Deregister instance
$ aws elb deregister-instances-from-load-balancer --load-balancer-name cb99-elb-test --instances i-538a8c94
{
    "Instances": []
}

# Error from curl command
$ curl --include 'http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com?sleep=20'
HTTP/1.1 504 GATEWAY_TIMEOUT
Content-Length: 0
Connection: keep-alive

# re-register instance
$ aws elb register-instances-with-load-balancer --load-balancer-name cb99-elb-test --instances i-538a8c94
{
    "Instances": [
        {
            "InstanceId": "i-538a8c94"
        }
    ]
}

# enable connection draining
$ aws elb modify-load-balancer-attributes --load-balancer-name cb99-elb-test --load-balancer-attributes '{"ConnectionDraining": {"Enabled": true}}'
{
    "LoadBalancerAttributes": {
        "ConnectionDraining": {
            "Enabled": true,
            "Timeout": 300
        }
    },
    "LoadBalancerName": "cb99-elb-test"
}

# start curl command
$ curl --include 'http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com?sleep=20'
...

# deregister instance
$ aws elb deregister-instances-from-load-balancer --load-balancer-name cb99-elb-test --instances i-538a8c94
{
    "Instances": []
}

# curl command completes succesfully
$ curl --include 'http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com?sleep=20'
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Date: Sat, 09 Apr 2016 04:32:47 GMT
Server: WEBrick/1.3.1 (Ruby/2.0.0/2015-12-16)
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
Content-Length: 26
Connection: keep-alive

hello from ip-172-31-18-6

# retry curl
$ curl --include 'http://cb99-elb-test-328870456.us-west-2.elb.amazonaws.com'
HTTP/1.1 503 Service Unavailable: Back-end server is at capacity
Content-Length: 0
Connection: keep-alive

```

### Lab 5 - ELB: Delete ELB

```bash
# Checked monitoring graphs and deleted load balancer (forgot to screenshot graphs)
$ aws elb delete-load-balancer --load-balancer-name cb99-elb-test
$
```

### Lab 6 - ASG: Create Auto-Scaling Group

### Lab 7 - ASG: Create ASG with ELB

### Lab 8 - ASG: Health check

### Lab 9 - ASG: Manual scaling

### Lab 10 - ASG: Dynamic scaling (optional)
