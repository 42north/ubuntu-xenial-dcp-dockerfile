FROM ubuntu:16.04

# Run this so that apt-transport-https can be installed
RUN apt update
RUN apt -y upgrade
# Required to use the .NET Core repo
RUN apt -y install apt-transport-https
RUN apt -y upgrade
# Add the .NET Core repo to the repo list
RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
# Trust their key
RUN apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
# Add their packages to our apt list
RUN apt update
# Install the most recent host version
RUN apt -y install dotnet-host
# Install the most recent fxr version
RUN apt -y install dotnet-hostfxr-1.0.1
# Install the NET Core runtime
RUN apt -y install dotnet-sharedframework-microsoft.netcore.app-1.0.0
# Remove any packages left behind
RUN apt-get -y autoremove
# Remove all docs, apt archive lists and man pages
RUN rm -fR /usr/share/doc/*
RUN rm -fR /var/lib/apt/lists/*
RUN rm -fR /usr/share/man/*
