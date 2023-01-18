## Run the container locally
**If you have docker installed on your local machine and would like to test/explore the virtual desktop.**

### Build the image

```bash
$ docker build -t $(whoami)/$(basename ${PWD}) .
```

### Run the image
```bash
$ docker run --rm  -p 8888:8888 $(whoami)/$(basename ${PWD})
```

## Run the container on DSMLP
**If you are a UCSD student/worker and don't want to mess up with docker, you can ssh to DSMLP, our Machine Learning Cloud Platform, to try everything out.**

### Log into DSMLP with ssh
*Please consult Google if you don't know how to set up ssh.*
```bash
$ ssh <your ucsd username>@dsmlp-login.ucsd.edu # and enter your password
```

### launch the instance
```
$ launch.sh -i ghcr.io/ucsd-ets/pilot-vnc-desktop:main -m 8
```
**Note: '-m 8' specifies we will allocate 8GB of memory, which should be enough for most usage cases.**


## System info
Debian; X86_64 Arch; AMD64