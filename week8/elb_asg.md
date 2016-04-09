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
                "OwnerAlias": "123456789012",
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
    "OwnerId": "123456789012",
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
                    "OwnerId": "123456789012",
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
                "OwnerAlias": "123456789012",
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

![ELB Monitoring Graphs](https://raw.githubusercontent.com/ctbarrett/cldaws220/master/week8/elb_monitors.png)

```bash
# Checked monitoring graphs and deleted load balancer
$ aws elb delete-load-balancer --load-balancer-name cb99-elb-test
$

```

### Lab 6 - ASG: Create Auto-Scaling Group

```bash
# Create a launch configuration
$ aws autoscaling create-launch-configuration --launch-configuration-name cb99-launch-cfg --image-id ami-31d63951 --key-name cb99-w2 --security-groups sg-967e36f1 --instance-type t2.micro

# Create an autoscaling group
$ aws autoscaling create-auto-scaling-group --auto-scaling-group-name cb99-asg-test --launch-configuration-name cb99-launch-cfg --min-size 2 --max-size 4 --availability-zones us-west-2a us-west-2b us-west-2c

# List the autoscaling instances
$ aws autoscaling describe-auto-scaling-instances
{
    "AutoScalingInstances": [
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-26a8aee1",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-ba97c662",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        }
    ]
}

# Remove an instance
$ aws autoscaling terminate-instance-in-auto-scaling-group --instance-id i-ba97c662 --no-should-decrement-desired-capacity
{
    "Activity": {
        "Description": "Terminating EC2 instance: i-ba97c662",
        "ActivityId": "37abd34d-b2e4-4c9c-b79f-7515c46b67d1",
        "Details": "{\"Availability Zone\":\"us-west-2a\"}",
        "StartTime": "2016-04-09T05:01:39.043Z",
        "Progress": 0,
        "Cause": "At 2016-04-09T05:01:39Z instance i-ba97c662 was taken out of service in response to a user request.",
        "StatusCode": "InProgress"
    }
}

# Note the replacement instance launched (Pending) to backfill the old instance (Terminating)
$ aws autoscaling describe-auto-scaling-instances
{
    "AutoScalingInstances": [
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-26a8aee1",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8399c85b",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "Pending",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-ba97c662",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "Terminating",
            "LaunchConfigurationName": "cb99-launch-cfg"
        }
    ]
}

```

### Lab 7 - ASG: Create ASG with ELB

```bash
# Recreate ELB
$ aws elb create-load-balancer --load-balancer-name cb99-elb-test --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=4567" --subnets subnet-9a1023ff subnet-0494fd5d subnet-6f540518 --security-groups sg-7c7e361b
{
    "DNSName": "cb99-elb-test-2034046900.us-west-2.elb.amazonaws.com"
}

# Create new ASG with the recreated ELB
$ aws autoscaling create-auto-scaling-group --auto-scaling-group-name cb99-asg-elb-test --launch-configuration-name cb99-launch-cfg --min-size 2 --max-size 4 --load-balancer-names cb99-elb-test --availability-zones us-west-2a us-west-2b us-west-2c

# Test connectivity to new instances and traffic distribution
$ while : ; do curl http://cb99-elb-test-2034046900.us-west-2.elb.amazonaws.com/; sleep 1; done
hello from ip-172-31-38-65
hello from ip-172-31-13-205
hello from ip-172-31-38-65
hello from ip-172-31-13-205
hello from ip-172-31-38-65
^C
```

### Lab 8 - ASG: Health check

```bash
# setup curl monitor
$ while : ; do echo "$(date '+%H:%M:%S:') $(curl -s http://cb99-elb-test-2034046900.us-west-2.elb.amazonaws.com/)"; sleep 1; done
22:11:56: hello from ip-172-31-13-205
22:11:57: hello from ip-172-31-38-65
22:11:58: hello from ip-172-31-13-205
22:11:59: hello from ip-172-31-38-65
22:12:00: hello from ip-172-31-13-205
22:12:01: hello from ip-172-31-38-65
22:12:02: hello from ip-172-31-13-205
22:12:03: hello from ip-172-31-38-65
22:12:04: hello from ip-172-31-13-205
...

# SSH into one of the instances, and kill the webapp
[ec2-user@ip-172-31-13-205 ~]$ pgrep -fl ruby
2214 ruby -rsinatra -e set :bind, "0.0.0.0"; get "/" do; sleep params[:sleep].to_i if params[:sleep]; "hello from #{`hostname`}"; end; get "/png" do; "healthy\n"; end
[ec2-user@ip-172-31-13-205 ~]$ sudo pkill -9 ruby

# Noted the connections failing
22:16:10: hello from ip-172-31-13-205
22:16:12: hello from ip-172-31-38-65
22:16:13: hello from ip-172-31-13-205
22:16:14: hello from ip-172-31-38-65
22:16:15: hello from ip-172-31-13-205
22:16:16: hello from ip-172-31-38-65
22:16:17: hello from ip-172-31-38-65
22:16:18: hello from ip-172-31-38-65
22:16:19: hello from ip-172-31-38-65
22:16:20: hello from ip-172-31-38-65
...

# No new instances were added to the ASG
$ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name cb99-asg-elb-test
{
    "AutoScalingGroups": [
        {
            "AutoScalingGroupARN": "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:2ad5f578-96cd-4cd1-879c-3f9f8054ef3e:autoScalingGroupName/cb99-asg-elb-test",
            "HealthCheckGracePeriod": 0,
            "SuspendedProcesses": [],
            "DesiredCapacity": 2,
            "Tags": [],
            "EnabledMetrics": [],
            "LoadBalancerNames": [
                "cb99-elb-test"
            ],
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "DefaultCooldown": 300,
            "MinSize": 2,
            "Instances": [
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2a",
                    "InstanceId": "i-8498c95c",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                },
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2c",
                    "InstanceId": "i-7c7e68a6",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                }
            ],
            "MaxSize": 4,
            "VPCZoneIdentifier": "",
            "TerminationPolicies": [
                "Default"
            ],
            "LaunchConfigurationName": "cb99-launch-cfg",
            "CreatedTime": "2016-04-09T05:05:00.101Z",
            "AvailabilityZones": [
                "us-west-2c",
                "us-west-2b",
                "us-west-2a"
            ],
            "HealthCheckType": "EC2",
            "NewInstancesProtectedFromScaleIn": false
        }
    ]
}

$ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name cb99-asg-elb-test
{
    "AutoScalingGroups": [
        {
            "AutoScalingGroupARN": "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:2ad5f578-96cd-4cd1-879c-3f9f8054ef3e:autoScalingGroupName/cb99-asg-elb-test",
            "HealthCheckGracePeriod": 0,
            "SuspendedProcesses": [],
            "DesiredCapacity": 2,
            "Tags": [],
            "EnabledMetrics": [],
            "LoadBalancerNames": [
                "cb99-elb-test"
            ],
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "DefaultCooldown": 300,
            "MinSize": 2,
            "Instances": [
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2a",
                    "InstanceId": "i-8498c95c",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                },
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2c",
                    "InstanceId": "i-7c7e68a6",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                }
            ],
            "MaxSize": 4,
            "VPCZoneIdentifier": "",
            "TerminationPolicies": [
                "Default"
            ],
            "LaunchConfigurationName": "cb99-launch-cfg",
            "CreatedTime": "2016-04-09T05:05:00.101Z",
            "AvailabilityZones": [
                "us-west-2c",
                "us-west-2b",
                "us-west-2a"
            ],
            "HealthCheckType": "EC2",
            "NewInstancesProtectedFromScaleIn": false
        }
    ]
}

$ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name cb99-asg-elb-test
{
    "AutoScalingGroups": [
        {
            "AutoScalingGroupARN": "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:2ad5f578-96cd-4cd1-879c-3f9f8054ef3e:autoScalingGroupName/cb99-asg-elb-test",
            "HealthCheckGracePeriod": 0,
            "SuspendedProcesses": [],
            "DesiredCapacity": 2,
            "Tags": [],
            "EnabledMetrics": [],
            "LoadBalancerNames": [
                "cb99-elb-test"
            ],
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "DefaultCooldown": 300,
            "MinSize": 2,
            "Instances": [
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2a",
                    "InstanceId": "i-8498c95c",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                },
                {
                    "ProtectedFromScaleIn": false,
                    "AvailabilityZone": "us-west-2c",
                    "InstanceId": "i-7c7e68a6",
                    "HealthStatus": "Healthy",
                    "LifecycleState": "InService",
                    "LaunchConfigurationName": "cb99-launch-cfg"
                }
            ],
            "MaxSize": 4,
            "VPCZoneIdentifier": "",
            "TerminationPolicies": [
                "Default"
            ],
            "LaunchConfigurationName": "cb99-launch-cfg",
            "CreatedTime": "2016-04-09T05:05:00.101Z",
            "AvailabilityZones": [
                "us-west-2c",
                "us-west-2b",
                "us-west-2a"
            ],
            "HealthCheckType": "EC2",
            "NewInstancesProtectedFromScaleIn": false
        }
    ]
}

# Update health check type
$ aws autoscaling update-auto-scaling-group --auto-scaling-group-name cb99-asg-elb-test --health-check-type ELB --health-check-grace-period 30

# Downed instance was terminated
[ec2-user@ip-172-31-13-205 ~]$ sudo pkill -9 ruby
[ec2-user@ip-172-31-13-205 ~]$
Broadcast message from root@ip-172-31-13-205
  (unknown) at 5:29 ...

The system is going down for power off NOW!
Connection to ec2-52-37-126-37.us-west-2.compute.amazonaws.com closed by remote host.
Connection to ec2-52-37-126-37.us-west-2.compute.amazonaws.com closed.

$ aws autoscaling describe-auto-scaling-instances
{
    "AutoScalingInstances": [
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-26a8aee1",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2c",
            "InstanceId": "i-7c7e68a6",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "UNHEALTHY",
            "LifecycleState": "Terminating",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8399c85b",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8498c95c",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        }
    ]
}

# A new instance was started
$ aws autoscaling describe-auto-scaling-instances
{
    "AutoScalingInstances": [
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-26a8aee1",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2c",
            "InstanceId": "i-7c7e68a6",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "UNHEALTHY",
            "LifecycleState": "Terminating",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8399c85b",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8498c95c",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-a4b0b663",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "Pending",
            "LaunchConfigurationName": "cb99-launch-cfg"
        }
    ]
}

# New instance entered service automatically
22:30:53: hello from ip-172-31-38-65
22:30:54: hello from ip-172-31-38-65
22:30:55: hello from ip-172-31-38-65
22:30:56: hello from ip-172-31-38-65
22:30:57: hello from ip-172-31-31-134
22:30:58: hello from ip-172-31-38-65
22:30:59: hello from ip-172-31-31-134
22:31:00: hello from ip-172-31-38-65
22:31:01: hello from ip-172-31-31-134
22:31:02: hello from ip-172-31-38-65
22:31:04: hello from ip-172-31-31-134
22:31:05: hello from ip-172-31-38-65
22:31:06: hello from ip-172-31-31-134
22:31:07: hello from ip-172-31-38-65
22:31:08: hello from ip-172-31-31-134
22:31:09: hello from ip-172-31-38-65
22:31:10: hello from ip-172-31-31-134
22:31:11: hello from ip-172-31-38-65
22:31:12: hello from ip-172-31-31-134
22:31:13: hello from ip-172-31-38-65
^C
```

### Lab 9 - ASG: Manual scaling

```bash
# Set desired capacity to 4
$ aws autoscaling set-desired-capacity --auto-scaling-group-name cb99-asg-elb-test --desired-capacity 4

# New servers coming online
$ aws autoscaling describe-auto-scaling-instances
{
    "AutoScalingInstances": [
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-26a8aee1",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8399c85b",
            "AutoScalingGroupName": "cb99-asg-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2a",
            "InstanceId": "i-8498c95c",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2c",
            "InstanceId": "i-a27a6c78",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "Pending",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2c",
            "InstanceId": "i-a37a6c79",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "Pending",
            "LaunchConfigurationName": "cb99-launch-cfg"
        },
        {
            "ProtectedFromScaleIn": false,
            "AvailabilityZone": "us-west-2b",
            "InstanceId": "i-a4b0b663",
            "AutoScalingGroupName": "cb99-asg-elb-test",
            "HealthStatus": "HEALTHY",
            "LifecycleState": "InService",
            "LaunchConfigurationName": "cb99-launch-cfg"
        }
    ]
}

# responses from all 4 web servers
...
22:39:28: hello from ip-172-31-38-65
22:39:29: hello from ip-172-31-3-141
22:39:30: hello from ip-172-31-18-134
22:39:31: hello from ip-172-31-31-134
22:39:32: hello from ip-172-31-38-65
22:39:33: hello from ip-172-31-3-141
22:39:34: hello from ip-172-31-18-134
22:39:35: hello from ip-172-31-31-134
22:39:36: hello from ip-172-31-38-65
22:39:37: hello from ip-172-31-3-141
22:39:38: hello from ip-172-31-18-134
22:39:40: hello from ip-172-31-31-134
22:39:41: hello from ip-172-31-38-65

```
