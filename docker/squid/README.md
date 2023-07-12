# Introduction

Docker build for squid with ssl bump and dynamic certificate generation. Mainly targetted for apt caching.

# Usage

## Build

```bash
docker build -t squid .
``` 

## Run

```bash
docker run -d --name squid -p 8000:8000 squid
```