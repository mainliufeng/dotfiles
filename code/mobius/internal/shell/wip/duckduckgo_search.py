import requests
import sys

def search_duckduckgo(query):
    url = 'https://api.duckduckgo.com/'
    params = {
        'q': query,
        'format': 'json',
        'pretty': 1
    }
    response = requests.get(url, params=params)
    return response.json()

# 示例查询
query = sys.argv[1]
result = search_duckduckgo(query)
print(result)
