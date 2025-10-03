import json
import os
import requests
import logging
from typing import Dict, Any

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handler para processar requisições de consulta de clientes por CPF.
    
    Args:
        event: Evento do API Gateway
        context: Contexto da função Lambda
    
    Returns:
        Resposta formatada para o API Gateway
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        # Extrair CPF do path parameter
        path_parameters = event.get('pathParameters', {})
        if not path_parameters or 'cpf' not in path_parameters:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'message': 'CPF parameter is required'
                })
            }
        
        cpf = path_parameters['cpf']
        
        # Fazer requisição para API externa
        api_url = f"{os.getenv('API_URL', 'https://api.example.com')}/customers/cpf/{cpf}"
        response = requests.get(api_url)
        
        # Verificar resposta da API
        response.raise_for_status()
        customer_data = response.json()
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(customer_data)
        }
        
    except requests.exceptions.RequestException as e:
        logger.error(f"Error calling external API: {str(e)}")
        return {
            'statusCode': 502,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Error calling external service'
            })
        }
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Internal server error'
            })
        }