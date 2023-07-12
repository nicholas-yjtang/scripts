# Introduction

Purpose of this docker build is to create an intermediate image that can be used if opencv is needed in a docker build.

# Usage

## Build

```bash
docker build -t opencv .
```

## Use in Dockerfile

```Dockerfile
FROM opencv as opencv
```