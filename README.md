# Alpine xfce4 noVNC

Simple and minimal Alpine Docker Image providing XFCE4 through html5 noVNC connection

Step by step tutorial on how this docker is created (https://www.youtube.com/watch?v=8IfTXJRAIJw)

<div align="center">
 
![preview](preview.png?raw=true "preview")

</div>

#### Updates

v0.1.2 removed password requirement for noVNC

v0.1.1 added firefox pulseaudio and audio support

v0.1.0 initial code

#### Build Image

```sh
git clone https://github.com/Wishmasterflo/Alpine_xfce4_noVNC.git
docker build -t alpine-xfce4 Alpine_xfce4_noVNC/
```

#### Run Image

```sh
docker run -it -p 6080:6080 -p 56780:56780 --name alpine-novnc alpine-xfce4
```

#### Connect With noVNC

Use modern browswer to connect to http://(docker ip):6080/vnc.html

the predefined password is `alpine`

#### LICENCE

MIT
