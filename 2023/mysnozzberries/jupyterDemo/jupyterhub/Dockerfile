FROM jupyter/base-notebook:latest
USER jovyan
RUN pip3 install PyJWT
RUN pip3 install oauthenticator
RUN pip3 install fargatespawner
COPY jupyterhub_config.py /etc/jupyterhub/jupyterhub_config.py
CMD ["jupyterhub","-f","/etc/jupyterhub/jupyterhub_config.py","--log-level=DEBUG"]