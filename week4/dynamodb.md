# Homework / Lab Exercises - Week 4

## Create a DynamoDB Table With a Hash Key

```bash
$ aws dynamodb create-table \
> --table-name server_roles \
> --key-schema KeyType=HASH,AttributeName=server \
> --attribute-definitions AttributeName=server,AttributeType=S \
> --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
{
    "TableDescription": {
        "TableArn": "arn:aws:dynamodb:us-east-1:123456789012:table/server_roles",
        "AttributeDefinitions": [
            {
                "AttributeName": "server",
                "AttributeType": "S"
            }
        ],
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0,
            "WriteCapacityUnits": 5,
            "ReadCapacityUnits": 5
        },
        "TableSizeBytes": 0,
        "TableName": "server_roles",
        "TableStatus": "CREATING",
        "KeySchema": [
            {
                "KeyType": "HASH",
                "AttributeName": "server"
            }
        ],
        "ItemCount": 0,
        "CreationDateTime": 1459911170.876
    }
}
```

## Insert 5-10 Items Having Various Key-Value Attributes

```bash
$ aws dynamodb batch-write-item --request-items \
'{"server_roles": [
  { "PutRequest": { "Item": { "server": {"S": "web01"}, "roles": {"SS": ["linux", "web"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "web02"}, "roles": {"SS": ["linux", "web"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "web03"}, "roles": {"SS": ["linux", "web"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "app01"}, "roles": {"SS": ["linux", "app"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "app02"}, "roles": {"SS": ["linux", "app"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "adm01"}, "roles": {"SS": ["linux", "mgmt"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "dev01"}, "roles": {"SS": ["laptop", "osx", "mgmt", "dev"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "db01"}, "roles": {"SS": ["linux", "db"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "rpt01"}, "roles": {"SS": ["windows", "bi_rpt"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "mail01"}, "roles": {"SS": ["linux", "mx", "dmz"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "ns1"}, "roles": {"SS": ["linux", "dns", "dmz"]} } } },
  { "PutRequest": { "Item": { "server": {"S": "ns2"}, "roles": {"SS": ["linux", "dns", "dmz"]} } } }
  ]
}'
```

## Perform a Get Item Request for Two of Them

```bash
$ aws dynamodb batch-get-item --request-items \
> '{
>   "server_roles": {
>     "Keys": [
>       { "server": {"S": "web01"} },
>       { "server": {"S": "dev01"} }
>     ]
>   }
> }'
{
    "UnprocessedKeys": {},
    "Responses": {
        "server_roles": [
            {
                "roles": {
                    "SS": [
                        "linux",
                        "web"
                    ]
                },
                "server": {
                    "S": "web01"
                }
            },
            {
                "roles": {
                    "SS": [
                        "dev",
                        "laptop",
                        "mgmt",
                        "osx"
                    ]
                },
                "server": {
                    "S": "dev01"
                }
            }
        ]
    }
}
```

## Perform a Scan Request for All Items

```bash
$ aws dynamodb scan --table-name server_roles
{
    "Count": 12,
    "Items": [
        {
            "roles": {
                "SS": [
                    "app",
                    "linux"
                ]
            },
            "server": {
                "S": "app01"
            }
        },
        {
            "roles": {
                "SS": [
                    "linux",
                    "web"
                ]
            },
            "server": {
                "S": "web02"
            }
        },
        {
            "roles": {
                "SS": [
                    "dmz",
                    "dns",
                    "linux"
                ]
            },
            "server": {
                "S": "ns2"
            }
        },
        {
            "roles": {
                "SS": [
                    "dmz",
                    "linux",
                    "mx"
                ]
            },
            "server": {
                "S": "mail01"
            }
        },
        {
            "roles": {
                "SS": [
                    "bi_rpt",
                    "windows"
                ]
            },
            "server": {
                "S": "rpt01"
            }
        },
        {
            "roles": {
                "SS": [
                    "db",
                    "linux"
                ]
            },
            "server": {
                "S": "db01"
            }
        },
        {
            "roles": {
                "SS": [
                    "linux",
                    "web"
                ]
            },
            "server": {
                "S": "web01"
            }
        },
        {
            "roles": {
                "SS": [
                    "dmz",
                    "dns",
                    "linux"
                ]
            },
            "server": {
                "S": "ns1"
            }
        },
        {
            "roles": {
                "SS": [
                    "linux",
                    "web"
                ]
            },
            "server": {
                "S": "web03"
            }
        },
        {
            "roles": {
                "SS": [
                    "app",
                    "linux"
                ]
            },
            "server": {
                "S": "app02"
            }
        },
        {
            "roles": {
                "SS": [
                    "linux",
                    "mgmt"
                ]
            },
            "server": {
                "S": "adm01"
            }
        },
        {
            "roles": {
                "SS": [
                    "dev",
                    "laptop",
                    "mgmt",
                    "osx"
                ]
            },
            "server": {
                "S": "dev01"
            }
        }
    ],
    "ScannedCount": 12,
    "ConsumedCapacity": null
}
```

## Delete one of the items and Delete the table

```bash
$ aws dynamodb delete-item --table-name server_roles --key '{"server": {"S": "web03"}}'
$ aws dynamodb get-item --table-name server_roles --key '{"server": {"S": "web03"}}'
$ aws dynamodb delete-table --table-name server_roles
{
    "TableDescription": {
        "TableArn": "arn:aws:dynamodb:us-east-1:123456789012:table/server_roles",
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0,
            "WriteCapacityUnits": 5,
            "ReadCapacityUnits": 5
        },
        "TableSizeBytes": 0,
        "TableName": "server_roles",
        "TableStatus": "DELETING",
        "ItemCount": 0
    }
}
```

## Create a DynamoDB Table With a Hash/Range Key

## Use a Range Key Having a Numeric Value

## Insert Items Using Same Hash Key, Varying Range Key

## Query for the Items Using the Range Key
