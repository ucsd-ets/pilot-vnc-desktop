
FROM ucsdets/datahub-base-notebook:2023.1-stable as datahub-base-notebook

USER root

RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y update \
 	&& apt-get install -y --no-install-recommends \
		dbus-x11 \
   		firefox \
   		xfce4 \
   		xfce4-panel \
   		xfce4-session \
   		xfce4-settings \
   		xorg \
   		xubuntu-icon-theme

# Remove light-locker to prevent screen lock
ARG TURBOVNC_VERSION=3.0.1
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get remove -y -q light-locker && \
   rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

ARG VIRTUALGL_VERSION=3.0.2
RUN cd /tmp && wget -q "https://sourceforge.net/projects/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb/download" -O "virtualgl_${VIRTUALGL_VERSION}_amd64.deb" && \
   apt-get install -y -q ./"virtualgl_${VIRTUALGL_VERSION}_amd64.deb" && \
   rm ./"virtualgl_${VIRTUALGL_VERSION}_amd64.deb" 


ARG JRD_COMMIT=7d9b2810669e22b5ecdcfee8d8f531c3da0ab8a9
RUN ID=`mktemp -d` && cd $ID \
	&& curl -L https://github.com/jupyterhub/jupyter-remote-desktop-proxy/tarball/${JRD_COMMIT} | tar xvzf - && \
	cd jupyterhub-jupyter-remote-desktop-proxy-$(echo $JRD_COMMIT | cut -c 1-7) && \
	mamba env update -n base --file environment.yml && \
	rm -rf ${ID}

RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y update \
 	&& apt-get install -y --no-install-recommends \
   		build-essential

# Patch for https://github.com/novnc/websockify/pull/542
COPY ./websocketproxy.patch ./jupyter_desktop.patch /tmp/
RUN     (cd /opt/conda/lib/python3.9/site-packages/websockify; patch -p0 < /tmp/websocketproxy.patch --batch)  && \
	(cd /opt/conda/lib/python3.9/site-packages/jupyter_desktop; patch -p0 < /tmp/jupyter_desktop.patch --batch) && \
	rm /tmp/websocketproxy.patch /tmp/jupyter_desktop.patch

# Install VSCode
RUN  curl -L -s -o /tmp/vsc.deb 'https://go.microsoft.com/fwlink/?LinkID=760868' && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/vsc.deb && \
 	rm /tmp/vsc.deb 

# VScode disables LD_PRELOAD, so copy wrapped passwd/group onto /etc versions
RUN chmod 0666 /etc/passwd /etc/group
RUN mkdir -p -m 0755 /etc/datahub-profile.d && \
        echo "( cp /tmp/passwd.wrap /etc/passwd && cp /tmp/group.wrap /etc/group ) 2>/dev/null" \
		> /etc/datahub-profile.d/vscode-etc-passwd.sh

# Update desktop launcher to run VScode "--no-sandbox" (user namespaces not available in our containers)
COPY ./vscode-desktop.patch /tmp
RUN     (cd /; patch -p0 < /tmp/vscode-desktop.patch ) && \
	rm /tmp/vscode-desktop.patch

# Install IntelliJ
RUN  curl -L -s -o /tmp/intellij.tar.gz 'https://download.jetbrains.com/idea/ideaIC-2022.3.1.tar.gz' 
RUN    mkdir -p /opt/idea && \
	tar -xzf  /tmp/intellij.tar.gz -C /opt/idea --strip-components 1 && \
    ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea && \
 	rm /tmp/intellij.tar.gz 

RUN apt-get install -y -q at-spi2-core

USER jovyan

