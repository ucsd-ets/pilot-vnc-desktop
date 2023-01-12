### Build the image

```bash
$ docker build -t $(whoami)/$(basename ${PWD}) .
```

### Run the image
```bash
$ docker run --rm  -p 8888:8888 $(whoami)/$(basename ${PWD})
```

### System info
Debian; X86_64 Arch; AMD64