FROM jupyter/base-notebook:lab-3.6.3
USER root
RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update -y
RUN apt-get install -y dotnet-sdk-7.0
COPY ./workingWithO365.ipynb ${HOME}
USER root
RUN chown -R 1000 ${HOME}
USER jovyan
RUN dotnet tool install -g Microsoft.dotnet-interactive
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install
