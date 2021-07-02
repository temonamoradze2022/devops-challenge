# Tabeo DevOps Challenge

A developer has created a system for booking space travel. The system has a server component that provides an API. It also has a cronjob component.
Imagine that the developer provides you with the below information and associated source files. The developer asks you to help with:

1. Create a Docker configuration to allow building and running of the server API on his local machine.
2. Create a CI/CD flow to deploy the server API and also the cronjob to a Kubernetes cluster.

Your task is to:
1. Create a Docker/Docker Compose configuration to build and run the server locally.
2. Create a deployment pipeline that will deploy the server and cronjob onto a Kubernetes cluster whenever the developer pushes to the repo.

Bonus tasks:
Incorporate the tests in the deployment pipeline.

Notes:
Please fork this repo to your GitHub account and do all work in your fork.
For Kubernetes deployment, please utilize one of the free tiers/options available (https://github.com/learnk8s/free-kubernetes is useful).
If you are having issues obtaining a free K8, then please contact us as soon as possible.

You will be given the contact information for the developer with whom you may ask questions just like in any real work situation. Feel free to contact the developer for any clarifications.


## Space Travel Booking System

## Quickstart

1. Install lastest version of postgresql and Go version 1.16+
2. Create a user (postgres) and a database (space)
3. Install tern following instructions here: `https://github.com/jackc/tern`
3. Run the migrations using tern
```
PGHOST=localhost PGDATABASE=space PGUSER=postgres PGPASSWORD=postgres tern migrate -m ./migrations
```
4. Get depedencies:
```   
go mod download
```
5. Build:
```
go build -o booking-server cmd/booking-server/main.go
```

6. Run 
```
./booking-server
```

Please setup environment variables:
Check the ones that are needed in the source file: `internal/pkg/config/config.go` around line 56

Run the write-hello (should be a cron running every 15 minutes but on Sundays only every hour)
============================================

(environment variables are the same [ look above ])

```
go run cmd/write-hello/main.go
```

Build swagger documentation
-----------------------------

```
curl -o ~/bin/swagger -O -J -L https://github.com/go-swagger/go-swagger/releases/download/v0.27.0/swagger_linux_amd64 && chmod a+x ~/bin/swagger

~/bin/swagger generate spec -m -c "spacetrouble/*" -o swagger.yml
```

Follow installations here:
`https://swagger.io/docs/open-source-tools/swagger-ui/usage/installation/`

See also in the end for document


#### Example Requests

Make a booking
```
curl --location --request POST 'http://localhost:5000/v1/bookings' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FirstName": "Giorgos",
    "LastName": "Komninos",
    "Gender": "male",
    "LaunchpadID": "5e9e4501f509094ba4566f84",
    "DestinationID": "05c7f2ca-aa9a-4ea8-a6d5-4cb691468830",
    "Date": "2021-10-25",
    "Birthday": "1928-12-01"
}'
```

Success status code is `201`
Sample Response body:

```
{
    "ID": "06539a98-ab56-4152-ba1a-c274f8fa87d8",
    "User": {
        "Birthday": "1928-12-01",
        "Gender": "male",
        "ID": "c6554ab3-40d5-4826-a47a-1f7f7896c04b",
        "FirstName": "Giorgos",
        "LastName": "Komninos"
    },
    "Flight": {
        "Date": "2021-10-25",
        "ID": "3e086bd3-a9cd-43ec-bbec-ef61f0e9bbbc",
        "LaunchpadID": "5e9e4501f509094ba4566f84",
        "Destination": {
            "ID": "05c7f2ca-aa9a-4ea8-a6d5-4cb691468830",
            "Name": "Mars"
        }
    },
    "Status": "active",
    "CreatedAt": "2021-04-07T10:29:47.874277686Z"
}
```

Fetch all bookings

```
curl --location --request GET 'http://localhost:5000/v1/bookings' \
--header 'Content-Type: application/json'
```

Success status code is `200`
Sample Response Body:

```
{
    "bookings": [
        {
            "ID": "06539a98-ab56-4152-ba1a-c274f8fa87d8",
            "User": {
                "Birthday": "1928-12-01",
                "Gender": "male",
                "ID": "c6554ab3-40d5-4826-a47a-1f7f7896c04b",
                "FirstName": "Giorgos",
                "LastName": "Komninos"
            },
            "Flight": {
                "Date": "2021-10-25",
                "ID": "3e086bd3-a9cd-43ec-bbec-ef61f0e9bbbc",
                "LaunchpadID": "5e9e4501f509094ba4566f84",
                "Destination": {
                    "ID": "05c7f2ca-aa9a-4ea8-a6d5-4cb691468830",
                    "Name": "Mars"
                }
            },
            "Status": "active",
            "CreatedAt": "2021-04-07T10:29:47.874277Z"
        }
    ],
    "limit": 10,
    "cursor": "MjAyMS0wNC0wN1QxMDoyOTo0Ny44NzQyNzdaLDA2NTM5YTk4LWFiNTYtNDE1Mi1iYTFhLWMyNzRmOGZhODdkOA=="
}
```

**Notice**:
Results are paginated.
Use the cursor as a query parameter to fetch the next page


## Run the tests

```
go test -tags=test -v ./...
```

The tests are using [testcontainers-go](https://github.com/testcontainers/testcontainers-go) to start
a real database in a docker contaner.

Notes:
    I added tests only for the booking service to check that the business rules are enforced.


### Notes for Development

To generate the swagger documentation and run locally

Note: Replace the mount point with your own path
```
mkdir -p ~/swagger-docs
swagger generate spec -m -i "spacetrouble*" -o ~/swagger-docs/swagger.yml
docker run -p 5001:8080 -e SWAGGER_JSON=/foo/swagger.yml -v /home/yourUserName/swagger-docs/swagger.yml:/foo/swagger.yml swaggerapi/swagger-ui
```

Create a new migration:

```
PGHOST=localhost PGDATABASE=space PGUSER=postgres tern new initial_tbls -m ./migrations
```
