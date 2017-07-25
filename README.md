# DotNetCore.VsCode

Starts a full development environment for DotNetCore...

```
sudo ./vscode.sh build
```
It builds the image...
```
sudo ./vscode.sh run
```
It runs the image...

```
sudo docker run -d -p 9001:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock uifd/ui-for-docker
firefox 127.0.0.1:9001
```

