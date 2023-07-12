# Introduction

Docker build for squid with ssl bump and dynamic certificate generation. Specifically targetted to be used by some of my terraform scripts which may run a lot of apt install commands, so running this docker instance helps alleviate the long wait times on the apt install commands (especially on some of the band limited servers like opensuse for cri-o packages)

# Usage

## Build

```bash
docker build -t squid .
``` 

## Run

```bash
docker run -d --name squid -p 8000:8000 squid
```