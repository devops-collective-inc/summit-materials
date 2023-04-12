FROM jupyter/base-notebook:latest
USER root
RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update -y
RUN apt-get install -y dotnet-sdk-7.0
USER jovyan
RUN dotnet tool install -g Microsoft.dotnet-interactive
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install