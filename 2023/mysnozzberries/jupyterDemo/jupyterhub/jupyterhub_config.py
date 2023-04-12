# Spawner Config
from fargatespawner import FargateSpawner
c.JupyterHub.spawner_class = FargateSpawner
c.FargateSpawner.aws_region = 'us-east-1'
c.FargateSpawner.aws_ecs_host = 'ecs.us-east-1.amazonaws.com'
c.FargateSpawner.notebook_port = 8888
c.FargateSpawner.notebook_scheme = 'http'
c.FargateSpawner.get_run_task_args = lambda spawner: {
    'cluster': 'jupyterLabs',
    'taskDefinition': 'JupyterLab:1',
    'overrides': {
        'containerOverrides': [{
            'command': spawner.cmd + [f'--port={spawner.notebook_port}', '--config=notebook_config.py'],
            'environment': [
                {
                    'name': name,
                    'value': value,
                } for name, value in spawner.get_env().items()
            ],
            'name': 'dotnet',
        }],
    },
    'count': 1,
    'launchType': 'FARGATE',
    'networkConfiguration': {
        'awsvpcConfiguration': {
            'assignPublicIp': 'ENABLED',
            'securityGroups': ['sg-012345678abcd0123'],
            'subnets':  ['subnet-abcd0123','subnet-0123abcd'],
        },
    },
}

import json
import boto3
from botocore.exceptions import ClientError
def get_secret():
    secret_name = "JupyterHub"
    region_name = "us-east-1"
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e
    secret = get_secret_value_response['SecretString']
    val = json.loads(secret)
    return val['client_secret']

#from fargatespawner import FargateSpawnerEC2InstanceProfileAuthentication
#c.FargateSpawner.authentication_class = FargateSpawnerEC2InstanceProfileAuthentication
from fargatespawner import FargateSpawnerECSRoleAuthentication
c.FargateSpawner.authentication_class = FargateSpawnerECSRoleAuthentication

# Spawn Config
c.Spawner.env_keep = ['PYTHONPATH', 'CONDA_ROOT', 'CONDA_DEFAULT_ENV', 'VIRTUAL_ENV', 'LANG', 'LC_ALL', 'JUPYTERHUB_SINGLEUSER_APP']
#c.Spawner.hub_connect_url = 'http://172.31.0.1:8888'
c.Spawner.hub_connect_url = 'https://jupyter.soule.aws.sentinel.com'
c.Spawner.start_timeout = 120

# Azure AD Config
from oauthenticator.azuread import AzureAdOAuthenticator
c.JupyterHub.authenticator_class = AzureAdOAuthenticator

c.Application.log_level = 'DEBUG'

c.AzureAdOAuthenticator.tenant_id = '0123abcd-01ab-ab01-abcd-0123abcd4567'

c.AzureAdOAuthenticator.oauth_callback_url = 'https://jupyter.soule.aws.sentinel.com/hub/oauth_callback'
c.AzureAdOAuthenticator.client_id = 'abcd0123-ab01-01ab-dcba-45670123abcd'
c.AzureAdOAuthenticator.client_secret = get_secret()
c.AzureAdOAuthenticator.scope = ['openid']
